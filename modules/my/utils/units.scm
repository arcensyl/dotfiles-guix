;;; Copyright © 2025 Arcensyl <dev@arcensyl.me>
;;;
;;; This file is NOT part of GNU Guix.
;;;
;;; This program is free software; you can redistribute it and/or modify it
;;; under the terms of the GNU General Public License as published by the Free
;;; Software Foundation; either version 3 of the License, or (at your option)
;;; any later version.
;;;
;;; This program is distributed in the hope that it will be useful, but
;;; WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
;;; or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
;;; for more details.
;;;
;;; You should have received a copy of the GNU General Public License along
;;; with this program.  If not, see <http://www.gnu.org/licenses/>.

(define-module (my utils units)
  #:use-module (srfi srfi-9)
  #:use-module (gnu)
  #:use-module (my utils misc))

(define registered-units (make-hash-table))
(define unit-queue (make-hash-table))
(define unit-finalization-marker #f)

(define after-unit-calls '())

(define-record-type <config-unit>
  (make-config-unit applicator hooked-units)
  config-unit?
  (applicator config-unit-applicator)
  (hooked-units config-unit-hooked-units set-config-unit-hooked-units!))

(define (finalize-units)
  (set! unit-finalization-marker #t))

(define-public (register-unit identifier applicator)
  (unless (or (symbol? identifier) (list-of-symbols? identifier))
    (error "A configuration unit's identifier must be a symbol or list of symbols"))
  
  (unless (procedure? applicator)
    (error "A configuration unit's applicator must be a procedure"))

  (hash-set! registered-units identifier (make-config-unit applicator '())))

(define-syntax define-unit
  (syntax-rules ()
    ((_ (name . args) body ...)
     (register-unit 'name
                    (lambda args body ...)))))
(export define-unit)

(define-syntax define-unit*
  (syntax-rules ()
    ((_ (name . args) body ...)
     (register-unit 'name
                    (lambda* args body ...)))))
(export define-unit*)

(define-public (hook-unit main hooked)
  (unless (and (or (symbol? main) (list-of-symbols? main))
               (or (symbol? hooked) (list-of-symbols? hooked)))
    (error "A configuration unit's identifier must be a symbol or list of symbols"))

  (unless (hash-ref registered-units hooked)
    (error "Attempted to hook a non-existent unit on another"))
  
  (let ((unit (hash-ref registered-units main)))
    (unless unit
      (error "Attempted to hook a unit onto a non-existent one"))

    (set-config-unit-hooked-units! unit
                                   (cons hooked (config-unit-hooked-units unit)))))

(define* (use-unit unit #:rest args)
  (when unit-finalization-marker
    (error "Attempted to mark a unit as used, but the unit queue is already finalized"))
  
  (unless (or (symbol? unit) (list-of-symbols? unit))
    (error "A configuration unit's identifier must be a symbol or list of symbols"))

  (unless (hash-ref registered-units unit)
    (error (format #f "Unit '~a' not found" unit)))

  (hash-set! unit-queue unit args))
(export use-unit)

(define* (call-after-units func #:rest args)
  (unless (procedure? func)
    (error "FUNC, passed to 'call-after-units', must be a procedure"))
  
  (set! after-unit-calls (cons (cons func args) after-unit-calls)))
(export call-after-units)

(define-syntax eval-after-units
  (syntax-rules ()
    ((_ body ...)
     (call-after-units
      (lambda () body ...)))))
(export eval-after-units)

(define (resolve-unit-queue)
  (let ((buffer '())
        (final-iteration #f))

    (let loop ()
      (set! final-iteration #t)
      
      (hash-for-each
       (lambda (unit _)
         (for-each
          (lambda (hooked)
            (unless (hash-ref unit-queue hooked)
              (set! final-iteration #f)
              (set! buffer (cons hooked buffer))))
          (config-unit-hooked-units (hash-ref registered-units unit))))
       unit-queue)

      (for-each
       (lambda (item)
         (hash-set! unit-queue item '()))
       buffer)

      (set! buffer '())
      (unless final-iteration (loop)))))

(define-public (apply-all-units)
  (resolve-unit-queue)
  (finalize-units)
    
  (hash-for-each
   (lambda (unit args)
     (let ((unit (hash-ref registered-units unit)))
       (apply (config-unit-applicator unit) args)))
   unit-queue)

  (for-each
   (lambda (call)
     (apply (car call) (cdr call)))
   after-unit-calls))

(define-public (using-unit? unit)
  (unless (or (symbol? unit) (list-of-symbols? unit))
    (error "A configuration unit's identifier must be a symbol or list of symbols"))

  (if (hash-get-handle unit-queue unit) #t #f))

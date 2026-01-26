;;; Copyright © 2025-2026 Arcensyl <dev@arcensyl.me>
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

;; TODO: Change all unit names to be lists.

(define-module (my utils units)
  #:use-module (gnu)
  #:use-module (guix records)
  #:use-module (my utils misc))

;; A hash map containing all units that have been registered.
;; Each key is a symbol or list representing a unit's name.
;; Each of their associated values will be the unit itself.
(define registered-units (make-hash-table))

;; A hash map containing all units marked as used.
;; Each key is a symbol or list representing a unit's name.
;; Each of their associated values is a list of arguments to pass to the unit's applicator.
(define unit-queue (make-hash-table))

;; This boolean tells us when the unit queue is finalized.
;; This means that no new units can be marked as used.
(define unit-finalization-marker #f)

;; A list of procedures to call after all units have been applied.
;; Each procedure will be called with zero arguments.
;; Return values do not matter, as they will be discarded.
(define after-unit-calls '())

;; Configuration units, called units for short, are the building blocks of my Guix configuration.
;; At its core, a unit is essentially allows for a conditional, deferred procedure call.
;; Units are defined with a procedure that they'll run when they are applied.
;; A unit must explictly be marked as 'used' to be applied.
(define-record-type* <config-unit>
  config-unit make-config-unit
  config-unit?
  
  (applicator config-unit-applicator
              (doc "The procedure called when this unit is applied."))
  
  (hooked-units config-unit-hooked-units
                (doc "A list of units to mark as used when this unit is.")))

;; (define (finalize-units)
;;   (set! unit-finalization-marker #t))

(define-public (register-unit name applicator)
  "Create and register a new unit with NAME and APPLICATOR.
You should prefer the 'define-unit' or 'define-unit*' macros over this procedure."
  (unless (or (symbol? name) (list-of-symbols? name))
    (error "A configuration unit's name must be a symbol or list of symbols"))
  
  (unless (procedure? applicator)
    (error "A configuration unit's applicator must be a procedure"))

  (hash-set! registered-units name (make-config-unit applicator '())))

(define-syntax-rule (define-unit (name . args) body ...)
  "Define a new unit, under NAME, that takes ARGS and runs BODY when applied.
Under the hood, this procedure uses ARGS and BODY to generate a lambda to use as the new unit's applicator."
  (register-unit 'name (lambda args body ...)))
(export define-unit)

(define-syntax-rule (define-unit* (name . args) body ...)
  "Like 'define-unit', but supports an extended argument list syntax.
Under the hood, this macro simply swaps the call to 'lambda' with 'lambda*'."
  (register-unit 'name (lambda* args body ...)))
(export define-unit*)

(define-public (hook-unit main hooked)
  "Hook unit MAIN to the unit HOOKED.
This means that when MAIN is marked as used, HOOKED will be marked too."
  (unless (and (or (symbol? main) (list-of-symbols? main))
               (or (symbol? hooked) (list-of-symbols? hooked)))
    (error "A configuration unit's identifier must be a symbol or list of symbols"))

  (unless (hash-ref registered-units hooked)
    (error "Attempted to hook a non-existent unit on another"))
  
  (let ((unit (hash-ref registered-units main)))
    (unless unit
      (error "Attempted to hook a unit onto a non-existent one"))

    (hash-set! registered-units main
               (config-unit
                (inherit unit)
                (hooked-units
                 (cons hooked (config-unit-hooked-units unit)))))
    ))

(define* (use-unit unit #:rest args)
  "Mark UNIT as used, and pass ARGS to its applicator.
This will error if the unit queue has been finalized."
  (when unit-finalization-marker
    (error "Attempted to mark a unit as used, but the unit queue is already finalized"))
  
  (unless (or (symbol? unit) (list-of-symbols? unit))
    (error "A configuration unit's identifier must be a symbol or list of symbols"))

  (unless (hash-ref registered-units unit)
    (error (format #f "Unit '~a' not found" unit)))

  (hash-set! unit-queue unit args))
(export use-unit)

(define* (call-after-units proc #:rest args)
  "Save PROC to a queue, and call it with ARGS after all units have been applied."
  (unless (procedure? proc)
    (error "PROC, passed to 'call-after-units', must be a procedure"))
  
  (set! after-unit-calls (cons (cons proc args) after-unit-calls)))
(export call-after-units)

(define-syntax-rule (eval-after-units body ...)
  "Evaluate BODY after all units have been applied.
This is essentially just a wrapper around 'call-after-units'."
  (call-after-units (lambda () body ...)))
(export eval-after-units)

;; TODO: Optimize this by using a worklist algorithm.

(define (resolve-unit-queue)
  "Resolve the unit queue so that all hooked units are properly marked as used.
Note that this procedure is fairly performance intensive.
While it probably won't break, this should only be ran once."
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
  "Apply all units, and then execute any deferred calls.
This procedure will also resolve the unit queue before finalizing it.
You should only run this once, after all units have been defined and marked as used."
  (resolve-unit-queue)
  ;;(finalize-units)
  (set! unit-finalization-marker #t)
    
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
  "Return '#t' if UNIT has been marked as used.
Otherwise, return '#f'.
This is only considered reliable after the unit queue has been finalized."
  (unless (or (symbol? unit) (list-of-symbols? unit))
    (error "A configuration unit's identifier must be a symbol or list of symbols"))

  (if (hash-get-handle unit-queue unit) #t #f))

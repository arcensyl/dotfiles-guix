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

(define-module (my utils defer)
  #:use-module (my utils misc))

(define ~deferred-queue~ (make-fluid #f))

(define-public (defer-available?)
  "Return #t if the 'defer' macro can currently be used.
If it can, this means we are inside a scope created by 'with-deferred'."
  (if (fluid-ref ~deferred-queue~) #t #f))

(define (push-deferred! promise)
  "Push PROMISE to the queue of the current 'with-deferred' scope.
Note that this queue is more like a stack; the promise added last will run first."
  (unless (defer-available?)
    (error "Attempted to use 'defer' outside of a 'with-deferred' expression"))

  (fluid-map! (lambda (lst) (cons promise lst))
              ~deferred-queue~))

(define (flush-deferred!)
  "Run all queued promises in the current 'with-deferred' scope.
After this, the queue will be emptied."
  (unless (defer-available?)
    (error "Attempted to flush queue of deferred promises outside of a 'with-deferred' expression"))

  (for-each force (fluid-ref ~deferred-queue~))
  (fluid-set! ~deferred-queue~ '()))

(define-syntax-rule (with-deferred body ...)
  "Run BODY while allowing for the use of the 'defer' macro.
When BODY is done, all deferred code will then be executed.
The return value of this macro will be the same as BODY."
  (with-fluid* ~deferred-queue~
    '()
    (lambda ()
      (let ((ret (begin body ...)))
        (flush-deferred!)
        ret))))
(export with-deferred)

(define-syntax-rule (defer body ...)
  "Delay the execution of BODY until the current scope of 'with-deferred' ends.
If used outside of a 'with-deferred' expression, this macro will emit an error.

Deferred code will run in the opposite order of each call to 'defer'.
For example, the body of the last 'defer' call will always run first."
  (push-deferred! (delay (begin body ...))))
(export defer)

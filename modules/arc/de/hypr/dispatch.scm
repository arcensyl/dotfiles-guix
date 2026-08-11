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

(define-module (arc de hypr dispatch)
  #:use-module (arc util codecs)
  #:use-module (arc util misc)
  #:use-module (arc de hypr codecs))

(define *dispatcher-macros* (make-hash-table))

(define-public (register-dispatcher-macro! name proc)
"Register PROC as a dispatcher macro under NAME.

This system is built on top of Hyprland's dispatcher system.
Instead of being a Hyprland dispatcher, these macros emit Lua code directly.
They allow you to implement advanced functionality within my dispatcher syntax.

At the minimum, PROC should take a single argument, EAGER?.
EAGER? determines if emitted Lua code should eagerly produce a value when ran.
EAGER? is basically the difference between calling or just defining a function.

PROC is assumed to return a string of valid Lua code."
  (unless (symbol? name)
    (error "Dispatcher macro's name must be a symbol"))

  (unless (procedure? proc)
    (error "Dispatcher macro must be a procedure"))

  (hashq-set! *dispatcher-macros* name proc))

(define-syntax-rule (define-dispatcher-macro (name args ...) body ...)
  "Define a dispatcher macro under NAME that takes ARGS.
When used, this macro will run BODY to produce a string of Lua code.
For more details, please see the documentation for 'register-dispatcher-macro!.

Under the hood, this wraps BODY in a lambda procedure that takes ARGS.
You can also use the expanded syntax of 'define*' for ARGS."
  (register-dispatcher-macro! 'name (lambda* (args ...) body ...)))
(export define-dispatcher-macro)

(define-public (qualify-hypr-dispatcher name)
  "Qualify the NAME of a Hyprland dispatcher.
This is just NAME prepended by 'hl.dsp.'.

NAME is expected to be a symbol."
  (string->symbol
   (string-append "hl.dsp."
                  (symbol->string name))))

;; TODO: Make expansion system account for arity mismatch.

(define* (expand-hypr-dispatcher dispatcher #:key eager?)
  "Convert DISPATCHER into a string of Lua code.
This will also run any dispatcher macros it finds.

EAGER? is used to control what happens when this Lua code runs.
If its #t, this dispatcher will immeditaly be executed.
For more details, please see the documentation for 'register-dispatcher-macro!'."
  (unless (and (list? dispatcher)
               (not (null? dispatcher))
               (symbol? (car dispatcher)))
    (error "Dispatcher must be a list starting with a symbol"))

  (let ((expander (hashq-ref *dispatcher-macros* (car dispatcher))))
    (if expander
        (apply expander eager? (cdr dispatcher))
        (string-append (if eager? "hl.dispatch(" "")
                       (encode hypr-call-codec
                               (qualify-hypr-dispatcher (car dispatcher))
                               (cdr dispatcher))
                       (if eager? ")" "")))))
(export expand-hypr-dispatcher)

(define (maybe-wrap-in-lua-function eager? expr)
  "Wrap Lua EXPR in an anonymous function if EAGER? is #f."
  (if (not eager?)
      (string-append "(function (...)\n"
                     "    return "
                     expr
                     "\nend)")
      expr))

;; Run the string EXPR, an arbitratry Lua expression.
;; For eager evaluation, this macro just expands to EXPR itself.
;; Otherwise, EXPR will be wrapped in an anonymous function.
(define-dispatcher-macro (dm.embed eager? expr)
  (if (string? expr)
      (maybe-wrap-in-lua-function eager? expr)
      (error "Lua expression must be a string")))

;; Return Lua VAL without modification.
;; This is mainly useful when combined with something like 'dm.begin'.
;; This macro's emitted Lua code is always eagerly evaluated.
(define-dispatcher-macro (dm.value _ val)
  (encode hypr-value-codec val))

;; Get the value of OBJ or any of its FIELDS.
;; You can specify multiple symbols to get the fields of other fields.
;; For example, '(dm.get val foo bar)' is equivalent to 'val.foo.bar'.
(define-dispatcher-macro (dm.get _ obj #:rest fields)
  (string-append (encode hypr-value-codec obj)
                 (if (null? fields) "" ".")
                 (string-join (map (lambda (f) (encode hypr-value-codec f))
                                   fields)
                              ".")))

;; Call Lua FUNC with ARGS and return the result.
(define-dispatcher-macro (dm.call eager? func #:rest args)
  (maybe-wrap-in-lua-function eager?
                              (encode hypr-call-codec func args)))

;; Like 'dm.call', but run each expression in DISPATCHERS before calling FUNC.
;; The return value of each dispatcher will be one of FUNC's passed arguments.
(define-dispatcher-macro (dm.call* eager? func #:rest dispatchers)
  (maybe-wrap-in-lua-function eager?
                              (string-append (encode hypr-value-codec func)
                                             "("
                                             (string-join (map (lambda (dsp)
                                                                 (expand-hypr-dispatcher dsp
                                                                                         #:eager? #t))
                                                               dispatchers)
                                                          ", ")
                                             ")")))

;; Compare the values of LEFT and RIGHT, returning true if they are equal.
;; When non-eager, create a predicate function that runs this comparison.
(define-dispatcher-macro (dm.eq eager? left right)
  (maybe-wrap-in-lua-function eager?
                              (string-append (encode hypr-value-codec left)
                                             " == "
                                             (encode hypr-value-codec right))))

(define-dispatcher-macro (dm.eq* eager? left right)
  (maybe-wrap-in-lua-function eager?
                              (string-append (expand-hypr-dispatcher left #:eager? #t)
                                             " == "
                                             (expand-hypr-dispatcher right #:eager? #t))))

;; If the dispatcher COND returns true, run the dipatcher THEN.
;; Otherwise, run the dispatcher ELSE.
;; Note that ELSE is optional.
(define-dispatcher-macro (dm.if eager? cond then #:optional else)
  (maybe-wrap-in-lua-function eager?
                              (string-append "if " (expand-hypr-dispatcher cond #:eager? #t)
                                             " then " (expand-hypr-dispatcher then #:eager? #t)
                                             
                                             (if else
                                                 (string-append " else "
                                                                (expand-hypr-dispatcher else #:eager? #t))
                                                 "")

                                             " end"))
  
;; Run each expression in DISPATCHERS, returning the final result.
;; This is similar to the 'begin' macro in Scheme itself.
;; Expressions can also access previous results through the 'val' table. 
(define-dispatcher-macro (dm.begin eager? #:rest dispatchers)
  (string-append (if eager? "pcall(" "")
                 "(function (...)\n"
                 "    local val = {}\n"
                 (string-join (map (lambda (dsp)
                                     (string-append "    val[#val+1] = "
                                                    (expand-hypr-dispatcher dsp #:eager? #t)
                                                    "\n"))
                                   dispatchers)
                              "")
                 "    return val[#val]\n"
                 (if eager? "end))" "end)")))

;; TODO: Add a dispatcher macros for working with Hyprland's timers.

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

(define-module (arc util misc)
  #:use-module (srfi srfi-1)
  #:use-module (ice-9 match))

;; This macro allows you to define a named procedure that matches on its first argument.
;; You can also specify additional arguments, though those aren't checked during pattern matching.
(define-syntax define-matcher
  (lambda (x)
    (syntax-case x ()
      ((_ (name matched args ...) doc clauses ...)
       (string? (syntax->datum #'doc))
       #'(define (name matched args ...) doc
           (match matched clauses ...)))
      
      ((_ (name matched args ...) clauses ...)
       #'(define (name matched args ...)
           (match matched clauses ...))))))
(export define-matcher)

(define (all-symbols? lst)
  "Return '#t' if all items in LST are symbols.
Otherwise, return '#f'.
You should prefer using the procedure 'list-of-symbols?' over this one."
  (cond
   ((null? lst) #t)
   ((not (symbol? (car lst))) #f)
   (else (all-symbols? (cdr lst)))))

(define-public (list-of-symbols? var)
  "Return '#t' if VAR is a list that only contains symbols.
Otherwise, return '#f'."
  (if (list? var)
      (all-symbols? var)
      #f))

(define-public (flatten lst)
  "Flatten LST to remove all nesting.
If LST has too much nesting, this procedure could cause a stack overflow."
  (fold-right (lambda (item acc)
                (if (list? item)
                    (append (flatten item) acc)
                    (cons item acc)))
              '()
              lst))

(define-public (flatten-map proc lst)
  "Flatten LST, and map over each value with PROC.
If LST has too much nesting, this procedure could cause a stack overflow."
  (fold-right (lambda (item acc)
                (if (list? item)
                    (append (flatten-map proc item) acc)
                    (cons (proc item) acc)))
              '()
              lst))

(define-syntax-rule (push! lst elt)
  "Modify LST by pushing ELT to the front of it."
  (set! lst (cons elt lst)))
(export push!)

(define-syntax-rule (boolean->true-or-false bool)
  "Return \"true\" or \"false\" depending on the value of BOOL."
  (if bool "true" "false"))
(export boolean->true-or-false)

(define-syntax-rule (boolean->yes-or-no bool)
  "Return \"yes\" or \"no\" depending on the value of BOOL."
  (if bool "yes" "no"))
(export boolean->yes-or-no)

(define* (list->hash-set lst #:optional (insert-fn hash-set!) (value #t))
  "Convert LST into a hash map.
Each item in LST will become a key, which all point to VALUE.
INSERT-FN, which defaults to 'hash-set!', will be used when populating the hash map."
  (let ((table (make-hash-table (length lst))))
    (for-each
     (lambda (item)
       (insert-fn table item value))
     lst)
    table))
(export list->hash-set)

(define* (alist->hash-map alst #:optional (insert-fn hash-set!))
  "Convert ALST to a hash map.
The car in each pair will become the keys, with the cdr being the value they'll point to.
If several pairs have the same car, the last one will overwrite the others.
INSERT-FN, which defaults to 'hash-set!', will be used when populating the hash map."
  (let ((table (make-hash-table (length alst))))
    (for-each
     (lambda (pair)
       (insert-fn table (car pair) (cdr pair)))
     alst)
    table))
(export alist->hash-map)

(define-public (hash-map->alist table)
  "Convert TABLE into an association list.
Each key will become a pair's car, with the respective value becoming the cdr."
  (hash-map->list (lambda (key val) (cons key val))
                  table))

(define-public (hash-keys table)
  "Return a list containing every key in TABLE."
  (hash-map->list (lambda (key _) key)
                  table))

(define-public (hash-values table)
  "Return a list containing every value in TABLE."
  (hash-map->list (lambda (_ val) val)
                  table))

(define* (maybe-wrap-string base #:optional prefix affix)
  "Conditionally wrap BASE with PREFIX and AFFIX.
If BASE is an empty string or '#f', return an empty string instead."
  (if (and base (not (equal? base "")))
      (string-append (or prefix "") base (or affix ""))
      ""))
(export maybe-wrap-string)

(define-syntax-rule (call-or-value obj)
  "If OBJ is a procedure, call it with no arguments and return the result.
Otherwise, return OBJ as is."
  (if (procedure? obj) (obj) obj))
(export call-or-value)

(define-syntax-rule (fluid-map! proc fluid)
  "Update FLUID, in the current dynamic root, by mapping over it with PROC."
  (fluid-set! fluid
              (proc (fluid-ref fluid))))
(export fluid-map!)

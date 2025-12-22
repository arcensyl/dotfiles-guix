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

(define-module (my utils misc))

(define (all-symbols? lst)
  (cond
   ((null? lst) #t)
   ((not (symbol? (car lst))) #f)
   (else (all-symbols? (cdr lst)))))

(define-public (list-of-symbols? var)
  (if (list? var)
      (all-symbols? var)
      #f))

(define-syntax boolean->true-or-false
  (syntax-rules ()
    ((_ bool)
     (if bool "true" "false"))))
(export boolean->true-or-false)

(define-syntax boolean->yes-or-no
  (syntax-rules ()
    ((_ bool)
     (if bool "yes" "no"))))
(export boolean->yes-or-no)

(define* (list->hash-set list #:optional (insert-fn hash-set!) (value #t))
  (let ((table (make-hash-table (length list))))
    (for-each
     (lambda (item)
       (insert-fn table item value))
     list)
    table))
(export list->hash-set)

(define* (alist->hash-map alist #:optional (insert-fn hash-set!))
  (let ((table (make-hash-table (length alist))))
    (for-each
     (lambda (pair)
       (insert-fn table (car pair) (cdr pair)))
     alist)
    table))
(export alist->hash-map)

(define-public (hash-map->alist table)
  (hash-map->list (lambda (key val) (cons key val))
                  table))

(define-public (hash-keys table)
  (hash-map->list (lambda (key _) key)
                  table))

(define-public (hash-values table)
  (hash-map->list (lambda (_ val) val)
                  table))

(define* (maybe-wrap-string base #:optional prefix affix)
  (if (and base (not (equal? base "")))
      (string-append (or prefix "") (or base "") (or affix ""))
      ""))
(export maybe-wrap-string)

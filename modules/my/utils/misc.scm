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

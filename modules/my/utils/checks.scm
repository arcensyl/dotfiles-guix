(define-module (my utils checks))

(define (all-symbols? lst)
  (cond
   ((null? lst) #t)
   ((not (symbol? (car lst))) #f)
   (else (all-symbols? (cdr lst)))))

(define-public (list-of-symbols? var)
  (if (list? var)
      (all-symbols? var)
      #f))

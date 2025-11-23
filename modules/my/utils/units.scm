(define-module (my utils units)
  #:use-module (gnu)
  #:use-module (my utils checks))

(define registered-units (make-hash-table))
(define unit-queue (make-hash-table))

(define-public (register-unit name applicator)
  (unless (or (symbol? name) (list-of-symbols? name))
    (error "The name of a configuration unit must be a symbol or list of symbols"))
  
  (unless (procedure? applicator)
    (error "The applicator of a configuration unit must be a procedure"))

  (hashq-set! registered-units name applicator))

(define* (use-unit unit #:rest args)
  (unless (or (symbol? unit) (list-of-symbols? unit))
    (error "Provide a symbol, or list of symbols, to specify the configuration unit to use"))

  (unless (hashq-ref registered-units unit)
    (error (format #f "Unit '~a' not found" unit)))

  (hashq-set! unit-queue unit args))
(export use-unit)

(define-public (apply-all-units)
  (hash-for-each
   (lambda (unit args)
     (let ((applicator (hashq-ref registered-units unit)))
       (apply applicator args)))
   unit-queue))

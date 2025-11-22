(define-module (my utils units)
  #:use-module (gnu))

(define registered-units (make-hash-table))
(define unit-queue (make-hash-table))

(define-public (register-unit name applicator)
  (unless (symbol? name)
    (error "The name of a configuration unit must be a symbol"))
  
  (unless (procedure? applicator)
    (error "The applicator of a configuration unit must be a procedure"))

  (hashq-set! registered-units name applicator))

(define* (use-unit unit #:rest args)
  (unless (symbol? unit)
    (error "Provide a symbol to specify the configuration unit to use"))

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

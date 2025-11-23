(define-module (my utils units)
  #:use-module (gnu)
  #:use-module (my utils checks))

(define registered-units (make-hash-table))
(define unit-queue (make-hash-table))

(define-public (register-unit name applicator)
  (unless (or (symbol? name) (list-of-symbols? name))
    (error "A configuration unit's identifier must be a symbol or list of symbols"))
  
  (unless (procedure? applicator)
    (error "A configuration unit's applicator must be a procedure"))

  (hashq-set! registered-units name applicator))

(define* (use-unit unit #:rest args)
  (unless (or (symbol? unit) (list-of-symbols? unit))
    (error "A configuration unit's identifier must be a symbol or list of symbols"))

  (unless (hashq-ref registered-units unit)
    (error (format #f "Unit '~a' not found" unit)))

  (hashq-set! unit-queue unit args))
(export use-unit)

(define-public (ensure-unit unit)
  (unless (or (symbol? unit) (list-of-symbols? unit))
    (error "A configuration unit's identifier must be a symbol or list of symbols"))

  (unless (hashq-ref registered-units unit)
    (error (format #f "Configuration unit '~a' not found" unit)))

  (let ((args (hashq-ref unit-queue unit)))
    (if args
        (hashq-set! unit-queue unit args)
        (hashq-set! unit-queue unit '()))))

(define-public (apply-all-units)
  (hash-for-each
   (lambda (unit args)
     (let ((applicator (hashq-ref registered-units unit)))
       (apply applicator args)))
   unit-queue))

(define-public (using-unit? unit)
  (unless (or (symbol? unit) (list-of-symbols? unit))
    (error "A configuration unit's identifier must be a symbol or list of symbols"))

  (if (hashq-get-handle registered-units unit) #t #f))

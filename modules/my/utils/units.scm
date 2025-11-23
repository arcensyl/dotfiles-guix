(define-module (my utils units)
  #:use-module (gnu)
  #:use-module (my utils misc))

(define registered-units (make-hash-table))
(define unit-queue (make-hash-table))

(define-public (register-unit name applicator)
  (unless (or (symbol? name) (list-of-symbols? name))
    (error "A configuration unit's identifier must be a symbol or list of symbols"))
  
  (unless (procedure? applicator)
    (error "A configuration unit's applicator must be a procedure"))

  (hash-set! registered-units name applicator))

(define* (use-unit unit #:rest args)
  (unless (or (symbol? unit) (list-of-symbols? unit))
    (error "A configuration unit's identifier must be a symbol or list of symbols"))

  (unless (hash-ref registered-units unit)
    (error (format #f "Unit '~a' not found" unit)))

  (hash-set! unit-queue unit args))
(export use-unit)

(define-public (ensure-unit unit)
  (unless (or (symbol? unit) (list-of-symbols? unit))
    (error "A configuration unit's identifier must be a symbol or list of symbols"))

  (unless (hash-ref registered-units unit)
    (error (format #f "Configuration unit '~a' not found" unit)))

  (let ((args (hash-ref unit-queue unit)))
    (if args
        (hash-set! unit-queue unit args)
        (hash-set! unit-queue unit '()))))

(define-public (apply-all-units)
  (hash-for-each
   (lambda (unit args)
     (let ((applicator (hash-ref registered-units unit)))
       (apply applicator args)))
   unit-queue))

(define-public (using-unit? unit)
  (unless (or (symbol? unit) (list-of-symbols? unit))
    (error "A configuration unit's identifier must be a symbol or list of symbols"))

  (if (hash-get-handle registered-units unit) #t #f))

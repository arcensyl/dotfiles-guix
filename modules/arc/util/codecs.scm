(define-module (arc util codecs)
  #:use-module (srfi srfi-1)
  #:use-module (gnu)
  #:use-module (arc util misc))

(define* (encode codec #:rest args)
  "Generate a string by calling CODEC with ARGS.
An error will be emitted if CODEC doesn't support ARGS.
If CODEC is #f, this procedure will use 'basic-codec' instead.

A codec is just a procedure that takes one or more arguments.
A codec's job is to turn all of its arguments into a single string.
If a codec doesn't support its arguments, it will return #f instead."
  (or (apply (or codec basic-codec) args)
      (errorf "Failed to encode: ~s" args)))
(export encode)

(define-public (make-encoder codec)
  "Make an encoder that takes an arbitrary number of arguments.
This new procedure will attempt to encode these arguments via CODEC.

When possible, you should prefer to call 'encode' directly.
This is useful when you need a procedure that has its codec built-in."
  (lambda* (#:rest args)
    (apply encode codec args)))

(define-public (basic-codec x)
  "A general-purpose codec that takes a single argument.
This codec mostly converts items directly into strings.

Note that this codec doesn't support lists or pairs."
  (cond
   ((string? x) x)
   ((symbol? x) (symbol->string x))
   ((number? x) (number->string x))
   ((boolean? x) (if x "true" "false"))
   (else #f)))

(define-public (prog-codec x)
  "A general-purpose codec that takes a single argument.
This codec aims to emulate syntax used in most programming languages.
For example, it'll automatically wrap a string in quotes."
  (cond
   ((string? x) (wrap-string x "\""))
   (else (basic-codec x))))

(define-public (y-or-n-codec x)
  "A simple codec that takes a boolean as its only argument.
Depending on that boolean's value, it will return \"yes\" or \"no\"."
  (if (boolean? x)
      (if x "yes" "no")
      #f))

(define* (make-list-codec inner #:optional (connector " "))
  "Make a codec that takes a list as its only argument.
Each element will be encoded using INNER, and then joined with CONNECTOR.
By default, CONNECTOR is a single space.

Elements not supported by INNER will automatically be filtered out."
  (lambda (x)
    (if (list? x)
        (string-join (filter-map inner x)
                     connector)
        #f)))
(export make-list-codec)

(define* (make-pair-codec inner #:optional val-codec (connector " "))
  "Make a codec that takes a pair as its only argument.
Both elements will be encoded using INNER, and then joined with CONNECTOR.
If VAL-CODEC is provided, it'll be used to encode the second element instead.
By default, CONNECTOR is a single space."
  (lambda (x)
    (if (pair? x)
        (let ((key (inner (car x)))
              (val ((or val-codec inner) (cdr x))))
          (if (and key val)
              (string-append key connector val)
              #f))
        #f)))
(export make-pair-codec)

(define* (make-kv-codec inner #:optional val-codec (connector " "))
  "Make a codec that takes two arguments, a key and a value.
Both arguments will be encoded using INNER, and then joined with CONNECTOR.
If VAL-CODEC is provided, it'll be used to encode the second argument instead.
By default, CONNECTOR is a single space."
  (let ((codec (make-pair-codec inner val-codec connector)))
    (lambda (k v) (codec (cons k v)))))
(export make-kv-codec)

;; TODO: Consider converting 'make-chain-codec' into a procedure.

(define-syntax-rule (make-chain-codec inner ...)
  "Make a codec that chains together one or more INNER codecs.
When encoding a value, the new codec will try each INNER one in order.

The new codec can take an arbitrary number of arguments.
INNER codecs are expected to have the same arity."
  (lambda* (#:rest args)
    (or (apply inner args) ...)))
(export make-chain-codec)

(define* (make-cond-codec inner #:optional (fallback ""))
  "Make a codec that takes one or more arguments.
These arguments will usually be encoded with INNER.
If any argument is #f, this codec will return FALLBACK instead.
By default, FALLBACK is an empty string."
  (lambda* (#:rest args)
    (if (every identity args)
        (apply inner args)
        fallback)))
(export make-cond-codec)

(define* (make-wrapping-codec inner prefix #:optional suffix)
  "Make a codec that takes one or more arguments.
These arguments will be encoded with INNER.

The encoded string will then be wrapped with PREFIX and SUFFIX.
If SUFFIX isn't provided, it'll default to the value of PREFIX."
  (lambda* (#:rest args)
    (let ((res (apply inner args)))
      (if res
          (wrap-string res prefix suffix)
          #f))))
(export make-wrapping-codec)

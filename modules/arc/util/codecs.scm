(define-module (arc util codecs)
  #:use-module (srfi srfi-1)
  #:use-module (srfi srfi-2)
  #:use-module (arc theming colors)
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
   ((color? x) (color->hex x))
   (else #f)))

;; TODO: Make 'prog-codec' escape quotes inside strings.

(define-public (prog-codec x)
  "A general-purpose codec that takes a single argument.
This codec aims to emulate the syntax used in many programming languages.
For example, it'll automatically wrap a string in quotes."
  (cond
   ((string? x) (wrap-string x "\""))
   ((color? x) (wrap-string (color->hex x) "\""))
   (else (basic-codec x))))

(define-public (y-or-n-codec x)
  "A simple codec that takes a boolean as its only argument.
Depending on that boolean's value, it will return \"yes\" or \"no\"."
  (if (boolean? x)
      (if x "yes" "no")
      #f))

(define-public (snake-codec x)
  "A simple codec that takes a symbol as its only argument.
The encoded symbol will be converted from kebab to snake case."
  (if (symbol? x)
      (string-map (lambda (c) (if (char=? c #\-) #\_ c))
                  (symbol->string x))
      #f))

;; TODO: Allow list codecs to work recursively.

(define* (make-list-codec inner #:optional (connector " "))
  "Make a codec that takes a list as its only argument.
Each element will be encoded using INNER, before they are joined into a string.
In this joined string, CONNECTOR will be used as the delimiter between elements.
By default, CONNECTOR is a single space.

Elements not supported by INNER will automatically be filtered out."
  (lambda (x)
    (if (list? x)
        (string-join (filter-map inner x)
                     connector)
        #f)))
(export make-list-codec)

(define* (make-variadic-codec inner #:optional (connector " "))
  "Make a codec that takes a variadic number of arguments.
All arguments will be encoded using INNER, and then joined with CONNECTOR.
By default, CONNECTOR is a single space.

Arguments not supported by INNER will be skipped over."
  (let ((codec (make-list-codec inner connector)))
    (lambda* (#:rest args) (codec args))))
(export make-variadic-codec)

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

(define-public (make-guarded-codec inner pred)
  "Wrap the codec INNER so its guarded by the procedure PRED.
When called, this codec will also call PRED with the same arguments.
If PRED returns #f, this codec will automatically fail and return #f too."
  (lambda* (#:rest args)
    (if (apply pred args)
        (apply inner args)
        #f)))

(define* (make-cond-codec inner #:optional (fallback ""))
  "Wrap the codec INNER to make it \"conditional\".
This new codec will return FALLBACK If any of its arguments are #f.
By default, FALLBACK is an empty string."
  (lambda* (#:rest args)
    (if (every identity args)
        (apply inner args)
        fallback)))
(export make-cond-codec)

(define-public (make-mapping-codec inner proc)
  "Wrap the codec INNER with string mapping logic.
When INNER returns a string, PROC will be called on each character."
  (lambda* (#:rest args)
    (and-let* ((res (apply inner args)))
      (string-map proc res))))

(define-public (make-recasing-codec inner upper?)
  "Wrap the codec INNER with case-changing, or \"recasing\", logic.
If UPPER? is #t, encoded strings will be converted to uppercase.
Otherwise, they'll be converted to lowercase instead."
  (lambda* (#:rest args)
    (and-let* ((res (apply inner args)))
      (if upper? (string-upcase res) (string-downcase res)))))

(define-public (make-filtering-codec inner char-pred)
  "Wrap the codec INNER with string filtering logic.
When INNER returns a string, it will be filtered with CHAR-PRED.

CHAR-PRED should be a procedure that takes a character.
It can also be character set if you want to test for membership."
  (lambda* (#:rest args)
    (and-let* ((res (apply inner args)))
      (string-filter char-pred res))))

(define-public (make-alphanumeric-codec inner)
  "Wrap the codec INNER to automatically exclude non-alphanumeric characters.
When INNER returns a string, it will be filtered with 'char-set:letter+digit'."
  (make-filtering-codec inner char-set:letter+digit))

(define-public (make-compact-codec inner)
  "Wrap the codec INNER to automatically exclude whitespace characters.
When INNER returns a string, it will be filtered with a character set.
This character set is the difference of 'char-set:full' and 'char-set:whitespace'."
  (make-filtering-codec inner (char-set-difference char-set:full
                                                   char-set:whitespace)))

(define* (make-wrapping-codec inner prefix #:optional suffix)
  "Wrap the codec INNER with string wrapping logic.
When INNER returns a string, it'll be wrapped with PREFIX and SUFFIX.
If SUFFIX isn't provided, PREFIX will be added to both sides."
  (lambda* (#:rest args)
    (and-let* ((res (apply inner args)))
      (wrap-string res prefix suffix))))
(export make-wrapping-codec)

;; This codec takes a single pair of integers.
(define-public resolution-codec
  (let ((nc (make-guarded-codec basic-codec number?)))
    (make-pair-codec nc #f "x")))

(define-public lua-value-codec
  (letrec ((vc (make-chain-codec tc snake-codec prog-codec))
           (pc (make-pair-codec snake-codec vc " = "))
           (lc (make-list-codec (make-chain-codec pc vc) ", "))
           (tc (make-wrapping-codec lc "{" "}")))
    vc))

(define-public lua-call-codec
  (let* ((lc (make-list-codec lua-value-codec ", "))
         (lc (make-wrapping-codec lc "(" ")")))
    (make-kv-codec snake-codec lc "")))

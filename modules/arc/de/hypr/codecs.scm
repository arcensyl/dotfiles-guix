(define-module (arc de hypr codecs)
  #:use-module (srfi srfi-1)
  #:use-module (arc util codecs)
  #:use-module (arc util keys)
  #:use-module (arc util misc))

;; This codec is for Hyprland's legacy configuration format, Hyprlang.
(define-public hyprlang-codec
  (let ((c (make-chain-codec y-or-n-codec basic-codec)))
    (make-kv-codec c #f " = ")))

(define (hypr-key-codec x)
  (if (keybind? x)
      (let ((mods (keybind-modifiers x))
            (key (keybind-key x))
            (variant (keybind-variant x)))
        (string-upcase
         (string-append "\""
                        (string-join (map key->xbd mods) " + ")
                        (if (null? mods) "" " + ")
                        (key->xbd key)
                        (if variant
                            (encode basic-codec variant)
                            "")
                        "\"")))
      #f))

;; As symbols can't easily include brackets, I've implemented my own indexing syntax.
;; You can index a table like 'V@N', where V is the table and N is the target index.
;; For example, 'arg@1' is equivalent to 'arg[1]'.
(define (hypr-index-codec x)
  (if (symbol? x)
      (let ((parts (string-split (symbol->string x) #\@)))
        (if (and (>= (length parts) 2)
                 (not (any string-null? parts)))
            (string-append (car parts)
                           "["
                           (string-join (cdr parts) "][")
                           "]")
            #f))
      #f))

;; TODO: Consider a full rewrite of the 'hypr-value-codec'.
;; Currently, its use of the Lua codec means that special types can't be used in tables.
;; By "special types", I'm referring to stuff like resolutions, keybinds, and indices with '@'.

(define-public hypr-value-codec
  (make-chain-codec hypr-key-codec
                    hypr-index-codec
                    lua-value-codec))

(define-public hypr-call-codec
  (let* ((lc (make-list-codec hypr-value-codec ", "))
         (lc (make-wrapping-codec lc "(" ")")))
    (make-kv-codec snake-codec lc "")))

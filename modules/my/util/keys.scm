;;; Copyright © 2025-2026 Arcensyl <dev@arcensyl.me>
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

(define-module (my util keys)
  #:use-module (ice-9 match)
  #:use-module (srfi srfi-14)
  #:use-module (gnu)
  #:use-module (guix records)
  #:use-module (my util misc))

;; This record represents a single keybind, consisting of a base key and several modifiers.
;; This is the core part of my target-agnostic keybinding API.
(define-record-type* <keybind>
  keybind make-keybind
  keybind?
  
  (key keybind-key
       (doc "The base key of this keybind.
This is usually a string, but is a symbol for special keys like 'home' and 'end'."))

  (modifiers keybind-modifiers
             (default '())
             (doc "A list of modifier keys that must be held for this keybind to trigger.
Each modifier key is represented by a symbol with that key's name, such as 'super'."))

  (variant keybind-variant
           (default #f)
           (doc "An integer specifying the 'variant' of the base key.
This is used for multiple keys that share the same symbol, such as function keys.
This is usually unused, and it defaults to '#f'.")))
(export keybind)

;; TODO: Reconsider the logic of the 'parse-key' function.

(define (parse-key key)
  "Parse KEY, the base key in a keybind.
This procedure is made for non-special keys directly represented in a keybind specification.
This includes all alphanumeric characters, and all symbols besides dashes and angle brackets."
  (when (= (string-length (string-trim-both key)) 0)
    (error "Key cannot be empty"))
  
  (unless (= (string-length key) 1)
    (error (format #f "Key '~a' should only contain one character" key)))
  
  key)

(define (get-key-variant key)
  "Return the variant specified by KEY.
Currently, only function keys have variants."
  (cond ((string-prefix? "<fn:" key)
         (let* ((key-no-prefix (string-drop key 4))
                (raw-code (string-drop-right key-no-prefix 1))
                (code (string->number raw-code)))
           (if code
               code
               (error "Function key arugment must be an integer"))))
        (else #f)))

(define (parse-special-key key)
  "Parse KEY, the base key in a keybind.
This is like 'parse-key', but for special keys that can't be directly represented in a keybind specification.
KEY should be a string containing the key's name surrounded by angle brackets.
Function keys should be specified like '<fn:N>', where N is the number of a specific function key."
  (unless (string-suffix? ">" key)
    (error (format #f "Key '~a' lacks a closing delimiter" key)))
  
  (match key
    ("<dash>" "-")
    ("<left_angle>" "<")
    ("<right_angle>" ">")
    
    ("<super>" 'super)
    ((or "<meta>" "<alt>") 'meta)
    ("<shift>" 'shift)
    ((or "<control>" "<ctrl>") 'control)
    
    ((or "<escape>" "<esc>") 'escape)
    ((or "<return>" "<ret>" "<enter>") 'return)
    ("<space>" 'space)
    ("<tab>" 'tab)
    
    ((or "<insert>" "<ins>") 'insert)
    ((or "<delete>" "<del>") 'delete)
    ("<home>" 'home)
    ("<end>" 'end)
    ("<print>" 'print)
    ("<page_up>" 'page-up)
    ("<page_down>" 'page-down)

    ("<up>" 'arrow-up)
    ("<down>" 'arrow-down)
    ("<left>" 'arrow-left)
    ("<right>" 'arrow-right)

    ((? (lambda (s) (string-prefix? "<fn:" s)) _) 'function)
    (other (error (format #f "Key '~a' is invalid" other)))))

(define (parse-modifier mod)
  "Parse MOD, a single character specifying a modifier key."
  (match (string-upcase mod)
    ("U" 'super)
    ("M" 'meta)
    ("C" 'control)
    ("S" 'shift)

    (other (error (format #f "Key '~a' is an invalid modifier" other)))))

(define-public (specification->keybind spec)
  "Parse SPEC into a keybind record.
A keybind specification follows an Emacs-like syntax, without support for chords.
For example, 'C-c' is the specification for the base key 'c' with the control modifier key.
Note that 'U' is used for the super modifier key, and 'M' is for the alt modifier key."
  (let* ((parts (reverse (string-split spec #\-)))
         (key (string-downcase (car parts)))
         (modifiers (reverse (cdr parts))))
    (keybind
     (key (if (string-prefix? "<" key)
              (parse-special-key key)
              (parse-key key)))
     
     (modifiers (map parse-modifier modifiers))

     (variant (get-key-variant key)))))

;; This macro parses SPEC into a keybind record.
;; This is basically a compile-time version of the 'specification->keybind' procedure.
;; To understand the specification format, please look at the docs of that procedure.
(define-syntax kb
  (lambda (x)
    (syntax-case x ()
      ((kb spec)
       (unless (string? (syntax->datum #'spec))
         (error "SPEC, passed to the 'kb' macro, must be a string literal"))

       (let* ((spec-str (syntax->datum #'spec))
              (parts (reverse (string-split spec-str #\-)))
              (key (string-downcase (car parts)))
              (modifiers (reverse (cdr parts))))
         #`(keybind
          (key #,(if (string-prefix? "<" key)
                   (let ((parsed (parse-special-key key)))
                     (if (symbol? parsed)
                         (datum->syntax x `',parsed)
                         (datum->syntax x parsed)))
                   (datum->syntax x (parse-key key))))
          (modifiers '(#,@(map
                           (lambda (m) (datum->syntax x (parse-modifier m)))
                           modifiers)))

          (variant #,(get-key-variant key))))))))
(export kb)

(define (key->xbd key)
  "Convert KEY to the name used for it in the XKB specification."
  (match key
    ("!" "exclam")
    ("#" "numbersign")
    ("$" "dollar")
    ("%" "percent")
    ("&" "ampersand")
    ("'" "apostrophe")
    ("\"" "quotedbl")
    ("," "comma")
    ("." "period")
    ("?" "question")
    ("_" "underscore")
    ("@" "at")
    ("`" "asciitilde")
    ("~" "grave")
    ("*" "asterisk")
    ("+" "plus")
    ("-" "minus")
    ("=" "equal")
    ("<" "less")
    (">" "greater")
    (";" "semicolon")
    (":" "colon")
    ("/" "slash")
    ("\\" "backslash")
    ("|" "bar")
    ("(" "parenleft")
    (")" "parenright")
    ("[" "bracketleft")
    ("]" "bracketright")
    ("{" "braceleft")
    ("}" "braceright")

    ('super "super")
    ('meta "alt")
    ('shift "shift")
    ('control "ctrl")
    ('escape "escape")
    ('space "space")
    ('tab "tab")
    ('insert "insert")
    ('delete "delete")
    ('home "home")
    ('end "end")
    ('print "print")
    ('page-up "prior")
    ('page-down "next")
    ('arrow-up "up")
    ('arrow-down "down")
    ('arrow-left "left")
    ('arrow-right "right")

    ('function "f")
    (other other)))

;; TODO: Move this to the same file defining a Hyprland service.
(define-matcher (keybind->hypr bind)
  "Convert BIND to a string following Hyprlang's syntax for keybinds."
  (($ <keybind> key modifiers variant)
   (string-upcase
    (string-append
     (string-join (map key->xbd modifiers))
     ", "
     (key->xbd key)
     (if variant (number->string variant) "")))))
(export keybind->hypr)

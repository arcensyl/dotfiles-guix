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

(define-module (arc theming colors)
  #:use-module (guix records)
  #:use-module (arc util misc))

(define-record-type* <color>
  color make-color
  color?

  (red color-red
       (default 0))

  (green color-green
         (default 0))
  
  (blue color-blue
        (default 0)))
(export color
        make-color
        color?
        color-red
        color-green
        color-blue)

(define-public (hex->color hex-string)
  (let ((hex (string-trim hex-string #\#)))
    (color
     (red (string->number (substring hex 0 2) 16))
     (green (string->number (substring hex 2 4) 16))
     (blue (string->number (substring hex 4 6) 16)))))

(define* (color->hex color #:optional no-prefix?)
  (string-append (if no-prefix? "" "#")
                 (string-pad (number->string (color-red color) 16) 2 #\0)
                 (string-pad (number->string (color-green color) 16) 2 #\0)
                 (string-pad (number->string (color-blue color) 16) 2 #\0)))
(export color->hex)

(define-record-type* <color-scheme>
  color-scheme make-color-scheme
  color-scheme?

  (base00 color-scheme-base00)  ; Default Background
  (base01 color-scheme-base01)  ; Lighter Background (status bars, line numbers)
  (base02 color-scheme-base02)  ; Selection Background
  (base03 color-scheme-base03)  ; Comments, Invisibles, Line Highlighting
  (base04 color-scheme-base04)  ; Dark Foreground (status bars)
  (base05 color-scheme-base05)  ; Default Foreground, Caret, Delimiters, Operators
  (base06 color-scheme-base06)  ; Light Foreground (not often used)
  (base07 color-scheme-base07)  ; Light Background (not often used)
  (base08 color-scheme-base08)  ; Variables, XML Tags, Markup Link Text, Markup Lists, Diff Deleted
  (base09 color-scheme-base09)  ; Integers, Boolean, Constants, XML Attributes, Markup Link Url
  (base0A color-scheme-base0A)  ; Classes, Markup Bold, Search Text Background
  (base0B color-scheme-base0B)  ; Strings, Inherited Class, Markup Code, Diff Inserted
  (base0C color-scheme-base0C)  ; Support, Regular Expressions, Escape Characters, Markup Quotes
  (base0D color-scheme-base0D)  ; Functions, Methods, Attribute IDs, Headings
  (base0E color-scheme-base0E)  ; Keywords, Storage, Selector, Markup Italic, Diff Changed
  (base0F color-scheme-base0F)) ; Deprecated, Opening/Closing Embedded Language Tags
(export color-scheme
        color-scheme?
        color-scheme-base00
        color-scheme-base01
        color-scheme-base02
        color-scheme-base03
        color-scheme-base04
        color-scheme-base05
        color-scheme-base06
        color-scheme-base07
        color-scheme-base08
        color-scheme-base09
        color-scheme-base0A
        color-scheme-base0B
        color-scheme-base0C
        color-scheme-base0D
        color-scheme-base0E
        color-scheme-base0F)

(define-public (color-dec-r base)
  (color
   (red (modulo (- (color-red base) 1) 255))
   (green (color-green base))
   (blue (color-blue base))))

(define-public (color-dec-g base)
  (color
   (red (color-red base))
   (green (modulo (- (color-green base) 1) 255))
   (blue (color-blue base))))

(define-public (color-dec-b base)
  (color
   (red (color-red base))
   (green (color-green base))
   (blue (modulo (- (color-blue base) 1) 255))))

;; The "Default Dark" color scheme by Chris Kempson.
;; Source: https://github.com/chriskempson/base16-default-schemes
(define %default-dark-color-scheme
  (color-scheme
    (base00 (hex->color "181818"))
    (base01 (hex->color "282828"))
    (base02 (hex->color "383838"))
    (base03 (hex->color "585858"))
    (base04 (hex->color "b8b8b8"))
    (base05 (hex->color "d8d8d8"))
    (base06 (hex->color "e8e8e8"))
    (base07 (hex->color "f8f8f8"))
    (base08 (hex->color "ab4642"))
    (base09 (hex->color "dc9656"))
    (base0A (hex->color "f7ca88"))
    (base0B (hex->color "a1b56c"))
    (base0C (hex->color "86c1b9"))
    (base0D (hex->color "7cafc2"))
    (base0E (hex->color "ba8baf"))
    (base0F (hex->color "a16946"))))

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

(define-module (my theming)
  #:use-module (srfi srfi-1)
  #:use-module (srfi srfi-2)
  #:use-module (ice-9 match)
  #:use-module (gnu)
  #:use-module (gnu home services)
  #:use-module (guix records)
  #:use-module (my core)
  #:use-module (my utils units)
  #:use-module (my utils misc))

(define-record-type* <theme>
  theme make-theme
  theme?

  (color-scheme theme-color-scheme)

  (wallpaper theme-wallpaper)

  (cursor theme-cursor))
(export theme
        theme-color-scheme
        theme-wallpaper
        theme-cursor)

(define-public current-theme (make-parameter #f))

(define-syntax-rule (with-theme theme body ...)
  (parameterize ((current-theme theme))
    body ...))
(export with-theme)

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

(define-public (get-color color-id)
  (unless (current-theme)
    (error "Function 'get-color' called while no current theme is set"))
  
  (match color-id
    ((or 0 'base00) (color-scheme-base00 (theme-color-scheme (current-theme))))
    ((or 1 'base01) (color-scheme-base01 (theme-color-scheme (current-theme))))
    ((or 2 'base02) (color-scheme-base02 (theme-color-scheme (current-theme))))
    ((or 3 'base03) (color-scheme-base03 (theme-color-scheme (current-theme))))
    ((or 4 'base04) (color-scheme-base04 (theme-color-scheme (current-theme))))
    ((or 5 'base05) (color-scheme-base05 (theme-color-scheme (current-theme))))
    ((or 6 'base06) (color-scheme-base06 (theme-color-scheme (current-theme))))
    ((or 7 'base07) (color-scheme-base07 (theme-color-scheme (current-theme))))
    ((or 8 'base08) (color-scheme-base08 (theme-color-scheme (current-theme))))
    ((or 9 'base09) (color-scheme-base09 (theme-color-scheme (current-theme))))
    ((or 10 'base0A) (color-scheme-base0A (theme-color-scheme (current-theme))))
    ((or 11 'base0B) (color-scheme-base0B (theme-color-scheme (current-theme))))
    ((or 12 'base0C) (color-scheme-base0C (theme-color-scheme (current-theme))))
    ((or 13 'base0D) (color-scheme-base0D (theme-color-scheme (current-theme))))
    ((or 14 'base0E) (color-scheme-base0E (theme-color-scheme (current-theme))))
    ((or 15 'base0F) (color-scheme-base0F (theme-color-scheme (current-theme))))
    
    (_ (error (format #f "Color identifier '~a' is not recognized" color-id)))))

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


(define-record-type* <cursor>
  cursor make-cursor
  cursor?

  (package cursor-package)
  
  (name cursor-name)

  (format cursor-format
          (default 'xorg))

  (size cursor-size
        (default 24)))
(export cursor
        cursor-package
        cursor-name
        cursor-format
        cursor-size)

(define-record-type* <theming-target>
  theming-target make-theming-target
  theming-target?

  (provision theming-target-provision)

  (file theming-target-file
        (default #f))

  (variables theming-target-variables
             (default '())))
(export theming-target)

(define base-cursor-target
  (theming-target
   (provision 'base-cursor)
   
    (variables
     (lambda ()
       (let* ((cursor (theme-cursor (current-theme)))
              (format (cursor-format cursor))
              (name (cursor-name cursor))
              (size (cursor-size cursor)))
         (match format
           ('xorg (list
                   (cons "XCURSOR_THEME" name)
                   (cons "XCURSOR_SIZE" (number->string size))))
           
           ('hypr (list
                   (cons "HYPRCURSOR_THEME" name)
                   (cons "HYPRCURSOR_SIZE" (number->string size))))
           
           (_ (error (format #f "Cursor format '~a' is invalid" format)))))))))

(define %default-theming-targets
  (list base-cursor-target))

(define-record-type* <home-theming-configuration>
  home-theming-configuration make-home-theming-configuration
  home-theming-configuration?

  (theme home-theming-configuration-theme)

  (targets home-theming-configuration-targets
           (default %default-theming-targets)))

(define-public home-theming-service-type
  (service-type
   (name 'home-theming)
   (description "Home service providing unified theme management.")
   
   (extensions
    (list
     (service-extension home-profile-service-type
                        (lambda (config)
                          (list
                           (cursor-package
                            (theme-cursor (home-theming-configuration-theme config))))))

     (service-extension home-files-service-type
                        (lambda (config)
                          (with-theme (home-theming-configuration-theme config)
                            (filter-map (lambda (target)
                                          (and-let* ((file (call-or-value (theming-target-file target))))
                                            (list (car file) (cdr file))))
                                        (home-theming-configuration-targets config)))))
     
     (service-extension home-environment-variables-service-type
                        (lambda (config)
                          (with-theme (home-theming-configuration-theme config)
                            (concatenate (map (lambda (target)
                                                (call-or-value
                                                 (theming-target-variables target)))
                                              (home-theming-configuration-targets config))))))))
   
   (compose concatenate)
   
   (extend
    (lambda (config targets)
      (home-theming-configuration
       (inherit config)
       (targets (append (home-theming-configuration-targets config)
                        targets)))))))

(define used-theme #f)

(define-public (use-theme theme)
  (set! used-theme theme))

(define-unit (theming)
  (unless used-theme
    (error "You must provide a theme, with 'use-theme', to use the 'theming' unit"))

  (use-home-service (service home-theming-service-type
                             (home-theming-configuration (theme used-theme)))))

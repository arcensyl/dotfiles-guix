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

(define-module (arc apps term kitty)
  #:use-module (gnu)
  #:use-module (gnu home)
  #:use-module (gnu home services)
  #:use-module (gnu packages terminals)
  #:use-module (guix records)
  #:use-module (arc core)
  #:use-module (arc theming)
  #:use-module (arc util features)
  #:use-module (arc util codecs)
  #:use-module (arc util files)
  #:use-module (arc util misc)
  #:use-module (arc system shells))

;; TODO: Add more options to configure Kitty.

;; TODO: Add the ability to define Kitty keybinds.

(define-record-type* <home-kitty-configuration>
  home-kitty-configuration make-home-kitty-configuration
  home-kitty-configuration?

  (package home-kitty-configuration-package
           (default kitty))

  (paste-actions home-kitty-configuration-paste-actions
                 (default '(quote-urls-at-prompt confirm)))
  
  (background-opacity home-kitty-configuration-background-opacity
           (default 1.0))

  (hide-window-decorations? home-kitty-configuration-hide-window-decorations?
                            (default #f))

  (window-padding home-kitty-configuration-window-padding
                  (default 0))
  
  (remember-window-size? home-kitty-configuration-remember-window-size?
                         (default #t))

  (initial-window-size home-kitty-configuration-initial-window-size
                       (default '(640 . 400)))

  (remember-window-position? home-kitty-configuration-remember-window-position?
                         (default #f))

  (audible-bell? home-kitty-configuration-audible-bell?
                 (default #t))

  (extra-options home-kitty-configuration-extra-options
                 (default '())))
(export home-kitty-configuration)

(define kitty-codec
  (let* ((bc (make-chain-codec y-or-n-codec basic-codec))
         (lc (make-list-codec bc ","))
         (c (make-chain-codec lc bc)))
    (make-variadic-codec c)))

(define (write-home-kitty-config config)
  (let ((paste-actions (home-kitty-configuration-paste-actions config))
        (win-size (home-kitty-configuration-initial-window-size config))
        (c kitty-codec))
    (mixed-text-file "kitty-theme.conf"
                     "### START OF GUIX CONFIG ###\n"
                     (as-joined-string "\n"
                       (encode c "paste_actions"
                               (if (null? paste-actions) '(no-op) paste-actions))
                       
                       (encode c "background_opacity"
                               (home-kitty-configuration-background-opacity config))
                       
                       (encode c "hide_window_decorations"
                               (home-kitty-configuration-hide-window-decorations? config))

                       (encode c "window_padding_width"
                               (home-kitty-configuration-window-padding config))
                       
                       (encode c "remember_window_size"
                               (home-kitty-configuration-remember-window-size? config))

                       (encode c "initial_window_width"  (car win-size))
                       (encode c "initial_window_height" (cdr win-size))

                       (encode c "remember_window_position"
                               (home-kitty-configuration-remember-window-position? config))

                       (encode c "enable_audio_bell"
                               (home-kitty-configuration-audible-bell? config))

                       (string-join (map (lambda (l) (apply encode c l))
                                         (home-kitty-configuration-extra-options config))
                                    "\n"))
                     "\n### END OF GUIX CONFIG ###\n\n")))

(define (write-home-kitty-theme)
  (let ((mono-font (theme-font-mono (current-theme)))
        (c kitty-codec))
    (cons ".config/kitty/kitty.conf"
          (mixed-text-file "kitty-theme.conf"
                           "### START OF GUIX THEME ###\n"
                           (as-joined-string "\n"
                             (encode c "font_family"          (font-name mono-font))
                             (encode c "font_size"            (font-size mono-font))

                             (encode c "background"           (get-color 'base00))
                             (encode c "foreground"           (get-color 'base05))

                             (encode c "selection_background" (get-color 'base02))
                             (encode c "selection_foreground" (get-color 'base05))

                             (encode c "cursor"               (get-color 'base05))
                             (encode c "cursor_text_color"    (get-color 'base00))

                             (encode c "url_color"            (get-color 'base0D))

                             ;; Normal
                             (encode c "color0"               (get-color 'base00))
                             (encode c "color1"               (get-color 'base08))
                             (encode c "color2"               (get-color 'base0B))
                             (encode c "color3"               (get-color 'base0A))
                             (encode c "color4"               (get-color 'base0D))
                             (encode c "color5"               (get-color 'base0E))
                             (encode c "color6"               (get-color 'base0C))
                             (encode c "color7"               (get-color 'base05))

                             ;; Bright
                             (encode c "color8"               (get-color 'base03))
                             (encode c "color9"               (get-color 'base08))
                             (encode c "color10"              (get-color 'base0B))
                             (encode c "color11"              (get-color 'base0A))
                             (encode c "color12"              (get-color 'base0D))
                             (encode c "color13"              (get-color 'base0E))
                             (encode c "color14"              (get-color 'base0C))
                             (encode c "color15"              (get-color 'base07))

                             ;; Extended
                             (encode c "color16"              (get-color 'base09))
                             (encode c "color17"              (get-color 'base0F))
                             (encode c "color18"              (get-color 'base01))
                             (encode c "color19"              (get-color 'base02))
                             (encode c "color20"              (get-color 'base04))
                             (encode c "color21"              (get-color 'base06)))
                           "\n### END OF GUIX THEME ###\n"))))

(define-public home-kitty-service-type
  (service-type
   (name 'home-kitty)
   (description "Home service to install and configure the Kitty terminal.")

   (default-value (home-kitty-configuration))
   
   (extensions
    (list
     (service-extension home-profile-service-type
                        (lambda (config)
                          (list
                           (home-kitty-configuration-package config))))

     (service-extension home-merge-files-service-type
                        (lambda (config)
                          (list (cons ".config/kitty/kitty.conf"
                                      (file->blocks (write-home-kitty-config config) 100)))))

     (service-extension home-theming-service-type
                        (lambda (_)
                          (list
                           (theming-target
                            (provision '(kitty))
                            (file write-home-kitty-theme)))))))))

(define-feature kitty
  (use-home-service
   (service home-kitty-service-type
            (home-kitty-configuration
             (paste-actions '(quote-urls-at-prompt
                              confirm
                              replace-newline))
             (background-opacity 0.9)
             (hide-window-decorations? #t)
             (window-padding 5)
             (remember-window-size? #f)
             (audible-bell? #f))))

  (run-on-shell-start
   "if test -n \"$KITTY_INSTALLATION_DIR\"; then
    source \"$KITTY_INSTALLATION_DIR/shell-integration/bash/kitty.bash\"
fi"
   #:where 'bash)

  (provide-shell-alias "kt" "kitten")
  (provide-shell-alias "icat" "kitten icat"))

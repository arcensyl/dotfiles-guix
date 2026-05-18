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

(define-module (arc de wallpaper)
  #:use-module (gnu)
  #:use-module (gnu services shepherd)
  #:use-module (gnu packages wm)
  #:use-module (gnu home)
  #:use-module (gnu home services)
  #:use-module (gnu home services shepherd)
  #:use-module (arc core)
  #:use-module (arc theming)
  #:use-module (arc system graphics))

;; TODO: Consider writing a custom package for AWWW.
;; AWWW is just a newer, renamed version of SWWW.

(define home-swww-shepherd-service
  (shepherd-service
   (documentation "Run the SWWW wallpaper daemon.")
   (provision '(swww))
   (requirement '(graphical-session))

   (start #~(make-forkexec-constructor
             (list #$(file-append swww "/bin/swww-daemon"))
             #:environment-variables (cons* (string-append "WAYLAND_DISPLAY="
                                                           #$(or (getenv "WAYLAND_DISPLAY")
                                                                 "wayland-1"))
                                            (default-environment-variables))))

   (stop #~(make-kill-destructor))))

;; TODO: Once I have a Hyprland service, have Hyprland interact with SWWW directly.

(define (write-home-swww-script)
  (cons ".dotfiles/guix/gen/swww-init.sh"
        (computed-file "swww-init.sh"
                       #~(begin
                           (call-with-output-file #$output
                             (lambda (port)
                               (display "#!/usr/bin/env bash\n\n" port)
                               (display (string-append "swww img -t none " 
                                                         #$(theme-wallpaper (current-theme)))
                                        port)
                               (display "\n" port)))
                           (chmod #$output #o755)))))

(define-public home-swww-service-type
  (service-type
   (name 'home-swww)
   (description "Home service for running the SWWW wallpaper daemon.")

   (default-value '())

   (extensions
    (list
     (service-extension home-profile-service-type
                        (lambda (_)
                          (list swww)))

     (service-extension home-shepherd-service-type
                        (lambda (_)
                          (list home-swww-shepherd-service)))

     (service-extension home-theming-service-type
                        (lambda (_)
                          (list
                           (theming-target
                            (provision '(swww))
                            (file write-home-swww-script)))))))))


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

(define home-awww-shepherd-service
  (shepherd-service
   (documentation "Run the AWWW wallpaper daemon.")
   (provision '(awww))
   (requirement '(graphical-session))

   (start #~(make-forkexec-constructor
             (list #$(file-append awww "/bin/awww-daemon"))
             #:environment-variables (cons* (string-append "WAYLAND_DISPLAY="
                                                           #$(or (getenv "WAYLAND_DISPLAY")
                                                                 "wayland-1"))
                                            (default-environment-variables))))

   (stop #~(make-kill-destructor))))

;; TODO: Once I have a Hyprland service, have Hyprland interact with AWWW directly.
;; TODO: Why does the generated AWWW script not have execute permission?

(define (write-home-awww-script)
  (cons ".dotfiles/guix/gen/awww-init.sh"
        (computed-file "awww-init.sh"
                       #~(begin
                           (call-with-output-file #$output
                             (lambda (port)
                               (display "#!/usr/bin/env bash\n\n" port)
                               (display (string-append "awww img -t none " 
                                                         #$(theme-wallpaper (current-theme)))
                                        port)
                               (display "\n" port)))
                           (chmod #$output #o755)))))

(define-public home-awww-service-type
  (service-type
   (name 'home-awww)
   (description "Home service for running the AWWW wallpaper daemon.")

   (default-value '())

   (extensions
    (list
     (service-extension home-profile-service-type
                        (lambda (_)
                          (list awww)))

     (service-extension home-shepherd-service-type
                        (lambda (_)
                          (list home-awww-shepherd-service)))

     (service-extension home-theming-service-type
                        (lambda (_)
                          (list
                           (theming-target
                            (provision '(awww))
                            (file write-home-awww-script)))))))))


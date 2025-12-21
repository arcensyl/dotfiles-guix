;;; Copyright © 2025 Arcensyl <dev@arcensyl.me>
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

(define-module (my system graphics)
  #:use-module (gnu)
  #:use-module (gnu services shepherd)
  #:use-module (gnu home services shepherd)
  #:use-module (my core)
  #:use-module (my utils units))

(define home-wayland-shepherd-service
  (shepherd-service
   (documentation "Dummy service indicating a Wayland session has started.")
   (provision '(wayland graphical-session))

   ;; HACK: Because of how Shepherd handles requirements, it will auto-start this service when another needs it.
   ;; This means that this service needs to block until it knows Wayland is running.
   ;; It does this by repeatdly checking for the existence of Wayland's socket.
   ;; Until that socket is created, this service will appear to be perpetually 'starting'.
   (start #~(lambda ()
              (let* ((runtime-path (or (getenv "XDG_RUNTIME_DIR")
                                       (string-append "/run/user/" (number->string (getuid)))))
                     (socket-path (string-append runtime-path "/wayland-1")))
                (let loop ()
                  (if (file-exists? socket-path)
                      #t
                      (begin
                        (sleep 1)
                        (loop)))))))
   
   (stop #~(lambda () #t))

   (auto-start? #f)
   (one-shot? #t)))

(define-unit ((system wayland))
  (use-home-packages
   ;; Wayland-specific Tools
   "wl-clipboard"

   ;; Tools useful across WMs
   "rofi")

  (use-home-service
   (simple-service 'register-home-wayland-shepherd-service
                   home-shepherd-service-type
                   (list home-wayland-shepherd-service))))

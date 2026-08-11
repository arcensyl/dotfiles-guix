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

(define-module (arc system hardware)
  #:use-module (gnu services)
  #:use-module (gnu services shepherd)
  #:use-module (gnu packages linux)
  #:use-module (guix gexp)
  #:use-module (arc core)
  #:use-module (arc util features)
  #:use-module (arc util defer))

(define-public system-brightness 50)

(define (brightness->string percent)
  (when (or (< percent 0)
            (> percent 100))
    (error "Brightness must be between 0% and 100%"))
  
  (string-append (number->string percent) "%"))

(define (auto-brightness-shepherd-service target)
  (shepherd-service
   (documentation "Automatically sets the default screen's brightness.")
   (provision '(auto-brightness))
   
   (requirement '(user-processes udev))

   (start #~(make-forkexec-constructor
             (list #$(file-append brightnessctl
                                  "/bin/brightnessctl")
                   "set"
                   #$(brightness->string target))))

   (one-shot? #t)
   (respawn? #f)))

(define-feature auto-brightness-dyn
  (defer
    (when (eq? system-type 'laptop)
      (use-service
       (simple-service 'auto-brightness
                       shepherd-root-service-type
                       (list (auto-brightness-shepherd-service system-brightness)))))))

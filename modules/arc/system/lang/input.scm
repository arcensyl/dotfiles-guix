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

(define-module (arc system lang input)
  #:use-module (gnu)
  #:use-module (gnu services shepherd)
  #:use-module (gnu packages fcitx5)
  #:use-module (gnu home)
  #:use-module (gnu home services)
  #:use-module (gnu home services shepherd)
  #:use-module (arc core)
  #:use-module (arc util features)
  #:use-module (arc util defer)
  #:use-module (arc system nix))

;; HACK: This entire setup is cursed.
;; As I use Mozc for Japanese input, I use the Nix package for Fcitx5.
;; This seems to work fine, though setting it up is a bit finicky.

;; TODO: Investigate allowing Fcitx to be configured with my home service.

(define home-fcitx-shepherd-service
  (shepherd-service
   (documentation "Run Fcitx, an input method framework.")
   (provision '(fcitx))
   (requirement '(graphical-session))
   
   (start #~(make-forkexec-constructor
             (list (string-append (getenv "HOME") "/.nix-profile/bin/fcitx5"))
             #:environment-variables (cons* (string-append "WAYLAND_DISPLAY="
                                                          #$(or (getenv "WAYLAND_DISPLAY")
                                                                "wayland-1"))
                                            
                                            (string-append "XDG_DATA_DIRS="
                                                           (getenv "HOME")
                                                           "/.nix-profile/share:"
                                                           (or (getenv "XDG_DATA_DIRS") ""))
                                            
                                            (string-append "FCITX_ADDON_DIRS="
                                                           (getenv "HOME")
                                                           "/.nix-profile/lib/fcitx5:"
                                                           (or (getenv "FCITX_ADDON_DIRS") ""))
                                            
                                            (default-environment-variables))))
   
   (stop #~(make-kill-destructor))))

;; TODO: Consider adding support for other versions of GTK (2, 4).

;; As Guix doesn't automatically detect Nix's Fcitx IM module, we need to tell GTK about it.
;; This cache file allows Guix GTK applications to use the module from Nix's 'fcitx5-gtk' package.

(define gtk3-immodules-cache
  (mixed-text-file "fcitx5-nix-immodule-gtk3.cache"
                   "\"" (getenv "HOME") "/.nix-profile/lib/gtk-3.0/3.0.0/immodules/im-fcitx5.so\"\n"
                   "\"fcitx\" \"Fcitx5\" \"gtk30\" \""
                   (getenv "HOME") "/.nix-profile/share/locale\" \"\" \n"))

(define home-fcitx-service-type
  (service-type
   (name 'home-fcitx)
   (description "Home service for running the Fcitx input method framework.")

   (default-value '())

   (extensions
    (list
     (service-extension home-flake-service-type
                        (lambda (_)
                          (list "fcitx5"
                                "fcitx5-gtk"
                                "kdePackages.fcitx5-configtool")))
     
     (service-extension home-environment-variables-service-type
                        (lambda (_)
                          `(("GUIX_GTK3_IM_MODULE_FILE" . ,gtk3-immodules-cache)
                            ("GTK_IM_MODULE" . "fcitx")
                            ("QT_IM_MODULE" . "fcitx")
                            ("XMODIFIERS" . "@im=fcitx"))))

     (service-extension home-shepherd-service-type
                        (lambda (_)
                          (list home-fcitx-shepherd-service)))))))
(export home-fcitx-service-type)

(define-feature input-methods
  (feat-require 'nix)

  (use-home-service
   (service home-fcitx-service-type)))

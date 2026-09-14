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

(define-module (arc system input)
  #:use-module (ice-9 match)
  #:use-module (gnu services)
  #:use-module (gnu services shepherd)
  #:use-module (gnu packages fcitx5)
  #:use-module (gnu home services)
  #:use-module (gnu home services shepherd)
  #:use-module (guix gexp)
  #:use-module (guix records)
  #:use-module (arc core)
  #:use-module (arc util features)
  #:use-module (arc util codecs)
  #:use-module (arc util keys)
  #:use-module (arc util defer)
  #:use-module (arc util misc)
  #:use-module (arc system nix)
  #:use-module (arc packages input))

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

(define-public (key->makima key)
  "Convert KEY to the name used for it by the Makima daemon."
  (match key
    ;; TODO: Add support for most symbol keys.
    
    ('super "KEY_LEFTMETA")
    ('meta "KEY_LEFTALT")
    ('shift "KEY_LEFTSHIFT")
    ('control "KEY_LEFTCTRL")
    ('escape "KEY_ESC")
    ('return "KEY_ENTER")
    ('print "KEY_SYSRQ") ;; TODO: Is this actually the 'print' key?
    ('page-up "KEY_PAGEUP")
    ('page-down "KEY_PAGEDOWN")
    ('arrow-up "KEY_UP")
    ('arrow-down "KEY_DOWN")
    ('arrow-left "KEY_LEFT")
    ('arrow-right "KEY_RIGHT")

    ('function "KEY_F")

    ;; Mouse buttons:
    ('mouse-left "BTN_LEFT")
    ('mouse-right "BTN_RIGHT")
    ('mouse-middle "BTN_MIDDLE")
    ('mouse-side-1 "BTN_EXTRA")
    ('mouse-side-2 "BTN_SIDE")
    
    ((? symbol? _) (string-append "KEY_"
                                  (string-upcase (symbol->string key))))
    
    (_ (string-append "KEY_" (string-upcase key)))))

(define (keybind->makima-string bind)
  (let ((key (keybind-key bind))
        (mods (keybind-modifiers bind)))
    (string-append (string-join (map key->makima mods)
                                "-")
                   (if (null? mods) "" "-")
                   (key->makima key))))

(define-record-type* <makima-device>
  makima-device make-makima-device
  makima-device?

  (name makima-device-name)

  (mappings makima-device-mappings
            (default '())))
(export makima-device
        makima-device?
        makima-device-name
        makima-device-mappings)

(define (makima-device-clean-name dev)
  (string-filter (lambda (c) (not (char=? c #\/)))
                 (makima-device-name dev)))

(define (makima-device-name->store-path dev)
  (string-append "makima-"
                 (string-map (lambda (c)
                               (if (char=? c #\space) #\_ c))
                             (makima-device-clean-name dev))
                 ".toml"))

(define (makima-device-name->etc-path dev)
  (string-append "makima/"
                 (makima-device-clean-name dev)
                 ".toml"))

(define (makima-device->file dev)
  (mixed-text-file (makima-device-name->store-path dev)
                   "[remap]\n"
                   (string-join (map (lambda (m)
                                       (encode toml-codec
                                               (keybind->makima-string (car m))
                                               (map keybind->makima-string (cdr m))))
                                     (makima-device-mappings dev))
                                "\n")))

(define makima-shepherd-service
  (shepherd-service
   (documentation "Run Makima, an input-remapping daemon.")
   (provision '(makima))
   (requirement '(udev))
   
   (start #~(make-forkexec-constructor
             (list #$(file-append makima "/bin/makima"))
             #:environment-variables (cons* "MAKIMA_CONFIG=/etc/makima"
                                            
                                            (string-append "PATH="
                                                           #$(getenv "PATH"))

                                            (string-append "WAYLAND_DISPLAY="
                                                          #$(or (getenv "WAYLAND_DISPLAY")
                                                                "wayland-1"))
                                            
                                            (default-environment-variables))
             #:log-file "/var/log/makima.log"))
   
   
   (stop #~(make-kill-destructor))))

(define-public makima-service-type
  (service-type
   (name 'makima)
   (description "Service for configuring and running Makima, an input-remapping daemon.")

   (default-value '())

   (extensions
    (list
     (service-extension shepherd-root-service-type
                        (const (list makima-shepherd-service)))

     (service-extension etc-service-type
                        (lambda (devices)
                          (map (lambda (dev)
                                 (list (makima-device-name->etc-path dev)
                                       (makima-device->file dev)))
                               devices)))))))

(define makima-device-queue '())

(define-public (use-makima-device dev)
  (push! makima-device-queue dev))

(define-feature input-methods
  (feat-require 'nix)

  (use-home-service
   (service home-fcitx-service-type)))

(define-feature makima
  (defer
    (use-service
     (service makima-service-type
              makima-device-queue))))

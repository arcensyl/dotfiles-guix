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

(define-module (my apps web nyxt)
  #:use-module (gnu)
  #:use-module (gnu packages lisp-xyz)
  #:use-module (gnu home)
  #:use-module (gnu home services)
  #:use-module (guix records)
  #:use-module (my core)
  #:use-module (my theming)
  #:use-module (my utils features)
  #:use-module (my utils misc)
  #:use-module (my packages nyxt))

(define-record-type* <home-nyxt-configuration>
  home-nyxt-configuration make-home-nyxt-configuration
  home-nyxt-configuration?

  (package home-nyxt-configuration-package
           (default nyxt)
           (doc "The package to install."))

  (extra-libraries home-nyxt-configuration-extra-libraries
                   (default '())
                   (doc "A list of Common Lisp libraries to install and expose to Nyxt.
Each item should be a file-like object pointing to a directory with an ASD file.")))
(export home-nyxt-configuration)

(define-public (prepare-nyxt-library package name)
  "Prepare a SBCL library to be exposed to Nyxt.
PACKAGE should contain the library itself.
NAME should specify the name of the directory containing this library's main 'asd' file.
This returns a <file-append> object which the caller should put into the Nyxt configuration record."
  (file-append package
               (string-append "/share/common-lisp/sbcl/" name "/")))

(define (write-home-nyxt-import-file config)
  "Using CONFIG, write a Nyxt configuration file allowing Nyxt to load additional libraries.
This works by pointing ASDF to the installed libaries inside the system store."
  (apply mixed-text-file
         "nyxt-guix-imports.lisp"
         (flatten
          (list
           "(in-package #:nyxt-user)\n\n"

           "(setf asdf:*central-registry*\n"
           "      (append asdf:*central-registry*\n"
           "              (list"

           (map (lambda (lib) (list (string-pad-right "\n" 16) "\"" lib "\""))
                (home-nyxt-configuration-extra-libraries config))
           
           ")))"))))

(define (write-home-nyxt-theme)
  "Write a theme for Nyxt based on the system's color scheme.
This procedure is used in Nyxt's target for the theming service.
It will error if called when the 'current-theme' parameter isn't set."
  (cons ".dotfiles/guix/gen/nyxt-guix-theme.lisp"
        (mixed-text-file "nyxt-guix-theme.lisp"
                         "(in-package #:nyxt-user)

(define-configuration browser
  ((theme (make-instance
           'theme:theme
           :background-color \"" (color->hex (get-color 'base00)) "\"
           :background-color+ \"" (color->hex (get-color 'base01)) "\"
           :background-color- \"" (color->hex (get-color 'base02)) "\"
           :primary-color \"" (color->hex (get-color 'base03)) "\"
           :primary-color+ \"" (color->hex (get-color 'base04)) "\"
           :primary-color- \"" (color->hex (get-color 'base02)) "\"
           :secondary-color \"" (color->hex (get-color 'base03)) "\"
           :secondary-color+ \"" (color->hex (get-color 'base02)) "\"
           :secondary-color- \"" (color->hex (get-color 'base04)) "\"

           :highlight-color \"" (color->hex (get-color 'base07)) "\"
           :highlight-color+ \"" (color->hex (get-color 'base07)) "\"
           :highlight-color- \"" (color->hex (get-color 'base07)) "\"
           :action-color \"" (color->hex (get-color 'base0D)) "\"
           :action-color+ \"" (color->hex (get-color 'base0D)) "\"
           :action-color- \"" (color->hex (get-color 'base0D)) "\"
           :success-color \"" (color->hex (get-color 'base0B)) "\"
           :success-color+ \"" (color->hex (get-color 'base0B)) "\"
           :success-color- \"" (color->hex (get-color 'base0B)) "\"
           :warning-color \"" (color->hex (get-color 'base0A)) "\"
           :warning-color+ \"" (color->hex (get-color 'base0A)) "\"
           :warning-color- \"" (color->hex (get-color 'base0A)) "\"

           :on-background-color \"white\"
           :on-primary-color \"white\"
           :on-secondary-color \"white\"
           :on-highlight-color \"white\"
           :on-action-color \"white\"
           :on-success-color \"white\"
           :on-warning-color \"white\"))))
")))

(define-public home-nyxt-service-type
  (service-type
   (name 'home-nyxt)
   (description "Home service to install Nyxt, the hacker's browser.")

   (default-value (home-nyxt-configuration))

   (extensions
    (list
     (service-extension home-profile-service-type
                        (lambda (config)
                          (list (home-nyxt-configuration-package config))))

     (service-extension home-files-service-type
                        (lambda (config)
                          (list
                           (list ".dotfiles/guix/gen/nyxt-guix-imports.lisp"
                                 (write-home-nyxt-import-file config)))))

     (service-extension home-theming-service-type
                        (lambda (_)
                          (list
                           (theming-target
                            (provision '(nyxt))
                            (file write-home-nyxt-theme)))))))))

(define-feature nyxt
  (use-home-service (service home-nyxt-service-type
                             (home-nyxt-configuration
                              (extra-libraries
                               (list (prepare-nyxt-library sbcl-slynk "slynk/slynk")
                                     (prepare-nyxt-library sbcl-cl-transducers "cl-transducers")))))))

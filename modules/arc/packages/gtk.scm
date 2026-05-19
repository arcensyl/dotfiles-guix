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

(define-module (arc packages gtk)
  #:use-module (guix packages)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix gexp)
  #:use-module (guix build-system copy)
  #:use-module (arc packages sources))

(define-public diinki-aero-gtk-theme
  (package
    (name "diinki-aero-gtk-theme")
    (version diinki-aero-version)

    (source (diinki-aero-source name))
    
    (build-system copy-build-system)
    
    (arguments
     `(#:install-plan
       '(("GTKTheme/diinki-aero" "share/themes/diinki-aero"))))
    
    
    (home-page "https://github.com/diinki/diinki-aero")
    (synopsis "Diinki Aero GTK theme")
    (description "A GTK 2/3/4 theme by diinki, inspired by the Frutiger Aero aesthetic.")
    (license license:gpl3)))

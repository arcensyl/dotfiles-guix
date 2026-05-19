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

(define-module (arc packages icons)
  #:use-module (guix packages)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix gexp)
  #:use-module (guix download)
  #:use-module (guix build-system copy)
  #:use-module (arc packages sources))

(define-public diinki-crystal-remix-icon-theme
  (package
    (name "diinki-crystal-remix-icon-theme")
    (version diinki-aero-version)

    (source (diinki-aero-source name))
    
    (build-system copy-build-system)
    
    (arguments
     `(#:install-plan
       '(("IconTheme/crystal-remix-icon-theme-diinki-version"
          "share/icons/diinki-crystal-remix"))))
    
    (home-page "https://github.com/diinki/diinki-aero")
    (synopsis "Crystal Remix icon theme (diinki version)")
    (description
     "A remix of the Crystal icon theme, customised by diinki.")
    (license license:gpl3)))

(define-public modernxp-cursor-theme
  (package
   (name "modernxp-cursor-theme")
   (version "1.0.1")

   (source
    (origin
     (method url-fetch)
     (uri "https://github.com/na0miluv/modernXP-cursor-theme/releases/download/final/ModernXP.tar.gz")
     (sha256
      (base32 "00xynqbf4p39yisjkjv0xykihla3brybryb5smkvc6cghcdrshsv"))))

   (build-system copy-build-system)
   
   (arguments
    `(#:install-plan
      '(("." "share/icons/ModernXP"))))

   (home-page "https://github.com/na0miluv/modernXP-cursor-theme")
   (synopsis "Modern XP theme for Xcursor")
   (description
    "XCursor theme made to be a pixel-perfect recreation of the classic Windows XP cursor set.")
   (license license:gpl3)))

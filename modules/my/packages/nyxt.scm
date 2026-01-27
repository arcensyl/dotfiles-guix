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

(define-module (my packages nyxt)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module ((sijo packages nyxt) #:prefix sijo:))

(define-public nyxt
  (package
   (inherit sijo:nyxt4)

   (version "4.0.0")

   (source
    (origin
     (method git-fetch)
     (uri (git-reference
           (url "https://github.com/atlas-engineer/nyxt")
           (commit "4.0.0")))
     (file-name (git-file-name "nyxt" version))
     (sha256
      (base32
       "08zqr1c91l5qzpzhli32lvam254lwsfbjrcxcm6a71plgdp0wvz2"))))))

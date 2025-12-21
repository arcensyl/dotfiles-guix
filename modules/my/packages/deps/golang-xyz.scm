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

(define-module (my packages deps golang-xyz)
  #:use-module (guix packages)
  #:use-module (guix licenses)
  #:use-module (guix git-download)
  #:use-module (guix build-system go))

(define-public go-github-com-danibezoff-perspective-transform
  (package
   (name "go-github-com-danibezoff-perspective-transform")
   (version "git-6a756ba")
   
   (source (origin
            (method git-fetch)
            (uri (git-reference
                  (url "https://github.com/danibezoff/perspective-transform")
                  (commit "6a756ba8e1bac0ae09426a1d085ff8eae4a0e5f1")))
            (file-name (git-file-name name version))
            (sha256
             (base32 "0lj78rzb9bip62wnlygbrwwiwl1f0jh4058gnsyd6brz0h5wcsp7"))))

   (build-system go-build-system)

   (arguments
    (list #:import-path "github.com/danibezoff/perspective-transform/perspective"
          #:unpack-path "github.com/danibezoff/perspective-transform"))

   (home-page "https://github.com/danibezoff/perspective-transform")
   (synopsis "Create and apply perspective transforms")
   (description "Create and apply perspective transforms")
   (license expat)))

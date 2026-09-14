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

(define-module (arc packages input)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages linux)
  #:use-module (guix packages)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix gexp)
  #:use-module (guix git-download)
  #:use-module (guix build-system cargo)
  #:use-module (arc packages deps rust-xyz))

(define rust-xyz
  '(arc packages deps rust-xyz))

(define-public makima
  (package
   (name "makima")
   (version "0.10.3")

   (source (origin
            (method git-fetch)
            (uri (git-reference
                  (url "https://github.com/cyber-sushi/makima")
                  (commit (string-append "v" version))))
            (file-name (git-file-name name version))
            (sha256
             (base32 "155s237xqrpdhap7i9fkpjc14qi2ax6g6bphmjvrm0yrdffvmsgz"))))

   (build-system cargo-build-system)

   (inputs (cargo-inputs 'makima-remapper #:module rust-xyz))

   (native-inputs
    (list pkg-config))

   (propagated-inputs
    (list eudev))
   
   (arguments
    (list
     #:phases
     #~(modify-phases %standard-phases
         (add-after 'install 'install-udev-rules
                    (lambda* (#:key outputs #:allow-other-keys)
                      (let* ((out (assoc-ref outputs "out"))
                             (src "50-makima.rules")
                             (dst (string-append out "/lib/udev/rules.d/")))
                        (mkdir-p dst)
                        (copy-file src (string-append dst src))))))))

   (home-page "https://github.com/cyber-sushi/makima")
   (synopsis "Input remapping daemon for Linux")
   (description "Makima is a daemon for Linux to remap keyboards, mice, controllers and tablets.")
   (license license:gpl3)))

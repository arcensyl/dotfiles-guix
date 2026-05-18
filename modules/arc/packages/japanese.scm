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

(define-module (arc packages japanese)
  #:use-module (gnu packages)
  #:use-module (gnu packages image-processing)
  #:use-module (gnu packages python-xyz)
  #:use-module (gnu packages python-build)
  #:use-module (gnu packages python-web)
  #:use-module (guix packages)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix gexp)
  #:use-module (guix utils)
  #:use-module (guix build utils)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module (guix build-system pyproject)
  #:use-module (arc packages deps python-xyz))

(define-public meikiocr
  (package
   (name "meikiocr")
   (version "0.3.1")

      (source (origin
            (method git-fetch)
            (uri (git-reference
                  (url "https://github.com/rtr46/meikiocr")
                  (commit "be47a276fcb8355a9a10eb865164d39477fa6afd")))
            (file-name (git-file-name name version))
            (sha256
             (base32 "1h4vcilzcic4c2vb80d846xcja9p8lvw4i6h0zddpjclk58d68sa"))))

      (build-system pyproject-build-system)

      (arguments
       (list #:phases
             #~(modify-phases %standard-phases
                              (delete 'sanity-check))))

      
      (native-inputs (list python-setuptools))

      (propagated-inputs
       (list python-numpy
             opencv
             python-huggingface-hub
             (list onnxruntime-non-static "python")))

      (home-page "https://github.com/rtr46/meikiocr")
      (synopsis "Local OCR for Japanese video games")
      (description "High-speed, high-accuracy, local OCR for Japanese video games.")
      (license license:asl2.0)))

;; TODO: Package Meikipop.

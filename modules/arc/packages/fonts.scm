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

(define-module (arc packages fonts)
  #:use-module (gnu packages compression)
  #:use-module (guix packages)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix gexp)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module (guix build-system copy)
  #:use-module (arc packages sources))

(define-public font-fairfax-hd
  (package
    (name "font-fairfax-hd")
    (version "2026-02-08")
    
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/kreativekorp/open-relay")
             (commit version)))
       (file-name (git-file-name name version))
       (sha256
        (base32 "1nw98ph6iqrms5ix2ap8b5nvr3ad1vgvxry7lxy6gf4dp36jky6s"))))
    
    (build-system copy-build-system)
    
    (arguments
     `(#:install-plan
       '(("FairfaxHD" "share/fonts/truetype/"
          #:include-regexp ("\\.ttf$")))))
    
    (home-page "http://www.kreativekorp.com/software/fonts/fairfaxhd")
    (synopsis "Fairfax HD monospace font")
    (description "Fairfax HD is a halfwidth scalable monospace font for terminals, text editors, IDEs, etc.")
    (license license:silofl1.1)))

(define-public font-maple-mono-normal-nl-nf-cn
  (package
    (name "font-maple-mono-normal-nl-nf-cn")
    (version "v7.9")
    
    (source
     (origin
      (method url-fetch)
      (uri "https://github.com/subframe7536/maple-font/releases/download/v7.9/MapleMonoNormalNL-NF-CN-unhinted.zip")
      (sha256
       (base32 "02vx6sqbsm11hikj7i6kmw0lbyjys12f0i5a98myzrk262zb9mhv"))))

    (build-system copy-build-system)

    (native-inputs (list unzip))
    
    (arguments
     `(#:install-plan
       '(("./" "share/fonts/truetype/"
          #:include-regexp ("\\.ttf$")))))
    
    (home-page "https://github.com/subframe7536/maple-font")
    (synopsis "Maple Mono font (normal, no ligatures, Nerd Fonts, CJK characters)")
    (description "Maple Mono is an open-source monospace font focused on smoothing your coding flow.")
    (license license:silofl1.1)))


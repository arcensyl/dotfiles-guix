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

(define-module (my packages misc)
  #:use-module (gnu packages golang-xyz)
  #:use-module (guix packages)
  #:use-module (guix licenses)
  #:use-module (guix git-download)
  #:use-module (guix build-system go)
  #:use-module (my packages deps golang-xyz))

(define-public craft-to-clonia-textures
  (package
   (name "craft_to_clonia_textures")
   (version "15dec25")
   
   (source (origin
            (method git-fetch)
            (uri (git-reference
                  (url "https://codeberg.org/ostech/craft_to_clonia_textures")
                  (commit version)))
            (file-name (git-file-name name version))
            (sha256
             (base32 "0jvgw4vxjvnbhd0m46z97iss2f98azbv3j19sp81wyby1h6mbsgb"))))

   (build-system go-build-system)
   
   (native-inputs
    (list go-github-com-disintegration-imaging
          go-github-com-danibezoff-perspective-transform))
 
   (arguments
    (list #:import-path "codeberg.org/ostech/craft_to_clonia_textures"
          #:tests? #f))

   (home-page "https://codeberg.org/ostech/craft_to_clonia_textures")
   (synopsis "Minecraft to Mineclonia texture pack converter")
   (description "Minecraft to Mineclonia texture pack converter")
   (license expat)))

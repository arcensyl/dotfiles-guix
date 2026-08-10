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

(define-module (arc packages misc)
  #:use-module (gnu packages)
  #:use-module (gnu packages commencement)
  #:use-module (gnu packages golang-xyz)
  #:use-module (gnu packages lua)
  #:use-module (gnu packages game-development)
  #:use-module (guix packages)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix gexp)
  #:use-module (guix git-download)
  #:use-module (guix build-system trivial)
  #:use-module (guix build-system copy)
  #:use-module (guix build-system go)
  #:use-module (arc packages deps golang-xyz))

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
   (license license:expat)))

(define-public (make-java-wrapper tag java-package)
  "Create a package that exposes JDK binaries under versioned names."
  (package
    (name (string-append "java" tag "-wrapper"))
    (version (package-version java-package))
    
    (source #f)
    
    (build-system trivial-build-system)
    
    (arguments
     (list
      #:modules '((guix build utils))
      #:builder
      #~(begin
          (use-modules (guix build utils))
          (let* ((out #$output)
                 (bin-out (string-append out "/bin"))
                 (jdk-bin (string-append #$java-package:jdk "/bin")))
            (mkdir-p bin-out)
            ;; Create symlinks or wrapper scripts for each binary
            (for-each
             (lambda (tool)
               (let ((src  (string-append jdk-bin "/" tool))
                     (dest (string-append bin-out "/"
                                          tool #$tag)))
                 (when (file-exists? src)
                   (symlink src dest))))
             '("java" "javac" "jar" "javadoc"))))))
    
    (synopsis (string-append "Wrapper for version " (package-version java-package) " of "(package-name java-package)))
    (description "Provides version-prefixed binaries for a specific Java package.")
    (license (package-license java-package))
    (home-page (package-home-page java-package))))

(define-public luajit-rubicon
  (package
   (inherit luajit-lua52-openresty)

   (name "luajit-rubicon")
   (version "2.1.0-R1.0")

   (source
    (origin
     (method git-fetch)
     (uri (git-reference
           (url "https://github.com/DreamWeave-MP/rubic0n")
           (commit (string-append "v" version))))
     (file-name (git-file-name name version))
     (sha256
      (base32 "0a8v1ymmx5ny4s8hjqgi6c3iwpwlg6sf2n31653ld0fnqxb1lsff"))))

   (home-page "https://github.com/DreamWeave-MP/rubic0n")
   (synopsis "LuaJIT fork optimized for the OpenMW game engine")
   (description "Rubic0n is a fork of LuaJIT designed to improve the performance of Lua scripts written for the OpenMW game engine.")
   (license license:expat)))

(define-public openmw-rubicon
  (package
   (inherit openmw)
   (name "openmw-rubicon")
   
   (inputs
    (modify-inputs (package-inputs openmw)
      (replace "luajit" luajit-rubicon)))

   (synopsis "OpenMW with optimized Lua scripting")
   (description "The OpenMW game engine with Rubic0n, a fork of LuaJIT optimized specifically for it.")))

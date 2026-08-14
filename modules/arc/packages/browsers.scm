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

(define-module (arc packages browsers)
  #:use-module (gnu packages bash)
  #:use-module (nongnu packages mozilla)
  #:use-module (guix gexp)
  #:use-module (guix packages)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix git-download)
  #:use-module (guix build-system trivial)
  #:use-module (guix build-system copy)
  #:use-module (guix utils)
  #:use-module (guix build utils)
  #:use-module ((sijo packages nyxt) #:prefix sijo:))

;; TODO: Switch to the upstream Nyxt package.

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

;; I couldn't get Geckium working on my machine, but I'm leaving these packages for now.
;; Installation seems to work fine; I think the issue is with Firefox or Geckium itself.

(define geckium-script
  (mixed-text-file "install-geckium.sh"
                   "#!" (file-append bash "/bin/bash") "
if [[ -z \"$1\" ]]; then
    echo \"Error: Profile not specified\" >&2
    exit 1
fi

package=\"$(dirname \"$(dirname \"$(readlink \"$0\")\")\")\"

if [[ ! -d \"$package\" ]]; then
    echo \"Error: Failed to locate the Geckium package\" >&2
    exit 2
fi

profile=\"$HOME/.mozilla/firefox/$1\"

if [[ ! -d \"$profile\" ]]; then
    echo \"Error: Profile '$1' not found\" >&2
    exit 3
fi

rm -rf \"$profile/chrome\"
ln -sf \"$package/share/geckium/profile/chrome\" \"$profile/chrome\"

theme_src=\"$package/share/geckium/profile/chrThemes\"

mkdir -p \"$profile/chrThemes\"
ln -sf \"$theme_src\"/*.crx \"$profile/chrThemes/\"
"))

(define-public geckium
  (package
   (name "geckium")
   (version "b0.20.99999")

   (source (origin
            (method git-fetch)
            (uri (git-reference
                  (url "https://github.com/angelbruni/Geckium")
                  (commit version)))
            (file-name (git-file-name name version))
            (sha256
             (base32 "04i0wyzjrjw4bzpxjqxk0pzr9yq49r32zdjr2al5302fwcayq13h"))))

   (build-system copy-build-system)

   (arguments
    (list #:install-plan
          #~'(("Firefox Folder" "share/geckium/firefox")
              ("Profile Folder" "share/geckium/profile"))

          #:phases
          #~(modify-phases %standard-phases
              (add-after 'install 'install-script
                         (lambda* (#:key outputs #:allow-other-keys)
                           (let ((bin (string-append #$output "/bin")))
                             (mkdir-p bin)
                             (copy-file #$geckium-script (string-append bin "/install-geckium"))
                             (chmod (string-append bin "/install-geckium") #o755)))))))

   (home-page "https://github.com/angelbruni/Geckium")
   (synopsis "Chrome 1-58 theme for Firefox 115+")
   (description "A modification for Firefox to make it resemble old versions of Chromium.")
   (license license:mpl2.0)))

(define-public firefox-geckium
  (package
   (name "firefox-geckium")
   (version (package-version firefox-esr))
   
   (source #f)
   
   (build-system trivial-build-system)

   (inputs (list firefox-esr))
   (propagated-inputs (list geckium))
   
   (arguments
    (list
     #:builder
     (with-imported-modules '((guix build utils))
       #~(begin
           (use-modules (guix build utils))
           
           (let* ((fo   (assoc-ref %outputs "out"))
                  (fi   (assoc-ref %build-inputs "firefox-esr"))
                  (geck (assoc-ref %build-inputs "geckium"))
                  (gi   (string-append geck "/share/geckium/firefox/"))
                  (go   (string-append fo "/lib/firefox-esr/")))
             (copy-recursively fi fo)
             (copy-recursively gi go))))))

   (synopsis "Trademarkless Firefox with Geckium")
   (description "The Firefox browser with the Geckium modification included.
Note that this is only the \"system\" side of Geckium.
To finish installation, you need to run the 'install-geckium' script.")
   (home-page (package-home-page firefox-esr))
   (license (package-license firefox-esr))))

;; FIXME: Ensure the Marble browser doesn't conflict with KDE application Marble.
;; In the developer's own Nix flake, they rename the binary to "marble-browser".
;; Maybe I should also do the same for my Guix package?

(define-public marble
  (package
   (inherit firefox-esr)

   (name "marble")
   (version "G2-b1.1")

   (source
    (origin
     (method git-fetch)
     (uri (git-reference
           (url "https://github.com/Erizur/Marble")
           (commit version)))
     (file-name (git-file-name "marble" version))
     (sha256
      (base32
       "1jdpbhk4ycbs3257hvhki45a5gha4c2xpnlvpb31gy8jssgnijnh"))))

   (arguments
    (substitute-keyword-arguments (package-arguments firefox-esr)
      ((#:phases phases)
       #~(modify-phases #$phases
           (replace 'wrap-program
                    (lambda* (#:key inputs outputs #:allow-other-keys)
                      (let* ((out (assoc-ref outputs "out"))
                             (lib (string-append out "/lib"))
                             (mesa-lib (string-append (assoc-ref inputs "mesa") "/lib"))
                             (libnotify-lib (string-append (assoc-ref inputs "libnotify") "/lib"))
                             (libva-lib (string-append (assoc-ref inputs "libva") "/lib"))
                             (pciaccess-lib (string-append (assoc-ref inputs "libpciaccess") "/lib"))
                             (pulseaudio-lib (string-append (assoc-ref inputs "pulseaudio") "/lib"))
                             (pipewire-lib (string-append (assoc-ref inputs "pipewire") "/lib"))
                             (eudev-lib (string-append (assoc-ref inputs "eudev") "/lib"))
                             (gtk-share (string-append (assoc-ref inputs "gtk+") "/share"))
                             (binary (or (false-if-exception
                                          (car (find-files lib "^marble$")))
                                         (error "Marble binary not found"))))
                        (wrap-program binary
                                      `("LD_LIBRARY_PATH" prefix (,mesa-lib ,libnotify-lib ,libva-lib
                                                                            ,pciaccess-lib ,pulseaudio-lib
                                                                            ,eudev-lib ,pipewire-lib))
                                      `("XDG_DATA_DIRS" prefix (,gtk-share))
                                      `("MOZ_LEGACY_PROFILES" = ("1"))
                                      `("MOZ_ALLOW_DOWNGRADE" = ("1"))
                                      `("MOZ_APP_REMOTINGNAME" = ("marble"))))))

           ;; NOTE: I chose to change Marble's vendor to "Erizur".
           ;; The project is no longer under the Network Neighborhood organization.
           ;; Erizur is the current developer, though the browser's branding hasn't been updated.
           ;; If the vendor is changed upstream, I'll modify or delete the following patch.
           
           (add-after 'unpack 'patch-branding
                      (lambda _
                        (substitute* "browser/moz.configure"
                                     (("imply_option\\(\"MOZ_APP_VENDOR\", .*\\)")
                                      "imply_option(\"MOZ_APP_VENDOR\", \"Erizur\")"))

                        (substitute* "browser/branding/official/branding.nsi"
                                     (("!define CompanyName .*")
                                      "!define CompanyName           \"Erizur\""))

                        (substitute* "browser/branding/official/locales/en-US/brand.ftl"
                                     (("^-vendor-short-name = .*") "-vendor-short-name = Erizur"))
                        #t))

           ;; TODO: Generate a custom desktop file for Marble.
           
           (delete 'install-desktop-entry)
           (delete 'install-icons)))))

   (home-page "https://github.com/Erizur/Marble")
   (synopsis "Firefox fork that aims to restore the Photon user interface.")
   (description "Firefox fork that aims to restore the Photon user interface.")))

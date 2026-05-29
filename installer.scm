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

(add-to-load-path "./modules")

(use-modules (guix gexp)
             (arc core)
             (arc util features)
             (arc util defer)
             (arc suites cli))

(set! system-name "guix-flash")
(set! system-type 'flash)

(set! master-name "admin")
(set! master-comment "Administrator")
(set! master-home-directory "/home/admin")

(define dotfiles-dir (string-append (getenv "HOME")
                                    "/.dotfiles"))

(with-deferred
 (feat-require 'core)
 (feat-require 'cli-common)
 (feat-require 'cli-modern)

 (use-packages
  ;; Storage and File Systems
  "dosfstools"
  "parted"

  ;; Misc.
  "neovim")

 (run-on-home-activation
  #~(begin
      (use-modules (guix build utils))

      (let ((uid (getuid))
            (gid (getgid))
            (src #$(local-file dotfiles-dir
                               "dotfiles"
                               #:recursive? #t))
            (dst #$(string-append master-home-directory
                                  "/.dotfiles")))
        (unless (file-exists? dst)
          (copy-recursively src dst)
          
          (delete-file-recursively (string-append dst "/guix/gen"))
          (mkdir (string-append dst "/guix/gen"))
          
          (chown dst uid gid)
          
          (for-each (lambda (f)
                      (chown f uid gid)

                      (if (directory-exists? f)
                          (chmod f #o755)    ; rwxr-xr-x
                          (chmod f #o644)))  ; rw-r--r--
                    (find-files dst
                                #:directories? #t
                                #:stat lstat)))))))

(make-system)

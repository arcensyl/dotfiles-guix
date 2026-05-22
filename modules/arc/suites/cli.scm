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

(define-module (arc suites cli)
  #:use-module (gnu)
  #:use-module (gnu packages dns)
  #:use-module (arc core)
  #:use-module (arc util features)
  #:use-module (arc system shells))

(define-feature cli-common
  (use-home-packages
   ;; System Information
   "lshw"
   "btop"
   "du-dust"

   ;; Networking
   "wget"
   (list isc-bind "utils")

   ;; Data Manipulation
   "jq"
   "yq"

   ;; Misc.
   "tealdeer"
   "fzf")

  (run-on-shell-start "eval \"$(fzf --bash)\""
                      #:where 'bash))

(define-feature cli-modern
  (use-home-packages
   "zoxide"
   "eza"
   "fd"
   "ripgrep"
   "bat")

  (run-on-shell-start "eval \"$(zoxide init bash)\""
                      #:where 'bash)

  (provide-shell-alias "cd" "z")
  
  (provide-shell-alias "ls" "eza --oneline --icons=always")
  (provide-shell-alias "ll" "eza --oneline --icons=always --long")

  (provide-shell-alias "cat" "bat"))

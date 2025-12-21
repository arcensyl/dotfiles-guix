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

(define-module (my suites cli)
  #:use-module (gnu)
  #:use-module (my core)
  #:use-module (my utils units)
  #:use-module (my system shells))

(define-unit* ((suites cli common) #:key disable-shell-integration?)
  (use-home-packages
   ;; System Information
   "lshw"
   "btop"
   "du-dust"

   ;; Networking
   "curl"
   "wget"

   ;; Data Manipulation
   "jq"
   "yq"

   ;; Misc.
   "tealdeer"
   "fzf")

  (unless disable-shell-integration?
    (run-on-shell-start "eval \"$(fzf --bash)\""
                        #:where 'bash)))

(define-unit* ((suites cli modern) #:key enable-aliases?)
  (use-home-packages
   "zoxide"
   "eza"
   "fd"
   "ripgrep"
   "bat")

  (run-on-shell-start "eval \"$(zoxide init bash)\""
                      #:where 'bash)

  (when enable-aliases?
    (provide-shell-alias "cd" "z")
    
    (provide-shell-alias "ls" "eza --oneline --icons=always")
    (provide-shell-alias "ll" "eza --oneline --icons=always --long")

    (provide-shell-alias "cat" "bat")))

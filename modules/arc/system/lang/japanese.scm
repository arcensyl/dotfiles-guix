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

(define-module (arc system lang japanese)
  #:use-module (gnu)
  #:use-module (arc core)
  #:use-module (arc util features)
  #:use-module (arc system nix)
  #:use-module (arc system lang input)
  #:use-module (arc system shells))

;; NOTE: To use Mozc, you will need to manually enable it in Fcitx's configuration.
;; If I add configuration support to my Fcitx service, I'll make this automatic.

(define-feature japanese
  (feat-require 'input-methods)
  
  (use-nix-packages
   ;; Input Methods
   "ibus-engines.mozc"
   "fcitx5-mozc"

   ;; Misc. Tools
   "jiten")

  (provide-shell-alias "jaw" "jiten jmdict -w")
  (provide-shell-alias "jak" "jiten kanji -e"))

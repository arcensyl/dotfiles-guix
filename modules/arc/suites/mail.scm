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

(define-module (arc suites mail)
  #:use-module (arc core)
  #:use-module (arc system nix)
  #:use-module (arc system shells)
  #:use-module (arc util features))

;; TODO: Write custom services so mail sync can be set up via Guix.
;; TODO: Write a Guix package for the 'oama' tool.

(define-feature mail
  (feat-require 'nix)
  
  (use-home-packages
   "isync"
   "cyrus-sasl-xoauth2"
   "msmtp"
   "mu")

  (use-nix-packages "oama")

  (provide-env-var "SASL_PATH" "$HOME/.guix-home/profile/lib/sasl2"))

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

(define-module (my system lang japanese)
  #:use-module (gnu)
  #:use-module (my core)
  #:use-module (my utils units)
  #:use-module (my system flatpak)
  #:use-module (my system lang input))

;; NOTE: To use Mozc, you will need to manually enable it in Fcitx's configuration.
;; If I add configuration support to my Fcitx service, I'll make this automatic.

;; TODO: Figure out how to get Emacs's 'mozc' package working with my bizarre setup.

(define-unit ((system lang japanese))
  (use-flatpaks "org.fcitx.Fcitx5.Addon.Mozc"))

(hook-unit '(system lang japanese) '(system lang input))

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

(define-module (arc packages sources)
  #:use-module (guix packages)
  #:use-module (guix git-download))

(define-public diinki-aero-version "2025-02-22")

(define-public (diinki-aero-source name)
  (origin
   (method git-fetch)
   (uri (git-reference
         (url "https://github.com/diinki/diinki-aero")
         (commit "630a7fc2ac1aa6160585cafa61967581e8b51376")))
   (file-name (git-file-name name diinki-aero-version))
   (sha256
    (base32 "02bl8wgcgrp52z237b0qhmnjycail7yq9gypl5fbx6r00a274rps"))))

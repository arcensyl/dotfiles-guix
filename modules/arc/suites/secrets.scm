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

(define-module (arc suites secrets)
  #:use-module (gnu)
  #:use-module (gnu home services gnupg)
  #:use-module (arc core)
  #:use-module (arc util features))

(define-feature secrets
  (use-home-packages "password-store")

  (use-home-service
   (service home-gpg-agent-service-type
            (home-gpg-agent-configuration
             (pinentry-program (file-append (specification->package "pinentry-qt")
                                            "/bin/pinentry"))
             (ssh-support? #t)))))

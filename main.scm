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

;; Welcome to Arc's Guix System configuration.
;; This is the entry point for my entire configuration.
;; It is responsible for ensuring my modules are available, loading host-specific files, and building the final `operating-system` record.
;; This file should be kept as minimal as possible, with machine-specific settings being specified in their relevant host directory.

;; Before doing anything else, we need to ensure Guix can find my modules.
(add-to-load-path "./modules")

(use-modules (arc core)
             (arc util defer)
             (arc util misc))

(unless system-name
  (error "Option 'system-name' is required, but was never set"))

(define host-config-file (string-append "./hosts/" system-name "/config.scm"))
(define host-hardware-file (string-append "./hosts/" system-name "/hardware.scm"))

(unless (file-exists? host-config-file)
  (errorf "No 'config.scm' file found for the host '~a'" system-name))

(unless (file-exists? host-hardware-file)
  (errorf "No 'hardware.scm' file found for the host '~a'" system-name))

(with-deferred
 (load host-config-file)
 (load host-hardware-file))

(make-system)

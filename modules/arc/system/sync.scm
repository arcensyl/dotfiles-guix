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

(define-module (arc system sync)
  #:use-module (gnu home services)
  #:use-module (gnu home services syncthing)
  #:use-module (arc core)
  #:use-module (arc util features)
  #:use-module (arc util defer)
  #:use-module (arc util misc))

(define *sync-dir-queue* '())

(define-public (use-synced-directory dir)
  "Configure Syncthing to keep DIR synchronized.
DIR must be a <syncthing-folder> record."
  (unless (syncthing-folder? dir)
    (error "Used synced directory isn't a <syncthing-folder> record"))

  (push! *sync-dir-queue* dir))

(define-feature file-sync
  (defer
    (use-home-service
     (service home-syncthing-service-type
              (for-home
               (syncthing-configuration
                (config-file
                 (syncthing-config-file
                  (folders *sync-dir-queue*)
                  (usage-reporting-accepted -1)
                  (start-browser? #f)))))))))

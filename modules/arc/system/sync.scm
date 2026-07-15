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
  #:use-module (ice-9 regex)
  #:use-module (gnu home services)
  #:use-module (gnu home services syncthing)
  #:use-module (arc core)
  #:use-module (arc util features)
  #:use-module (arc util defer)
  #:use-module (arc util misc))

;; HACK: The following code might be the most cursed thing I've written in Scheme.
;; This fixes an issue where the Syncthing service's generated config uses an outdated schema.
;; Syncthing will try and automatically update this config, causing conflicts with Guix.
;; This hack avoids this by overloading the config generator so it does the migration itself.

;; Please note that this solution is extremely fragile.
;; First of all, it'll need to be updated everytime Syncthing changes its schema.
;; Second, this will break whenever Guix updates to use a newer version of that schema.
;; Hopefully though, in the latter case, my fix will no longer be needed.

(let ((mod (resolve-module '(gnu services syncthing))))
  (define serialize-syncthing-config-file/base
    (module-ref mod 'serialize-syncthing-config-file))

  (module-set! mod 'serialize-syncthing-config-file
               (lambda (config)
                 (let* ((r1 (make-regexp "<configuration version=\"37\">"))
                        (r2 (make-regexp "</pullerPauseS>"))
                        (r3 (make-regexp "</sendXattrs>"))

                        (s1 "<configuration version=\"52\">")
                        (s2 "</pullerPauseS><pullerDelayS>1</pullerDelayS>")
                        (s3 "</sendXattrs><blockIndexing>true</blockIndexing>")
                        
                        (out (serialize-syncthing-config-file/base config))
                        (out (regexp-substitute/global #f r1 out 'pre s1 'post))
                        (out (regexp-substitute/global #f r2 out 'pre s2 'post))
                        (out (regexp-substitute/global #f r3 out 'pre s3 'post)))
                   out))))

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
                  (gui-apikey "guix-syncthing-key")
                  (start-browser? #f)))))))))

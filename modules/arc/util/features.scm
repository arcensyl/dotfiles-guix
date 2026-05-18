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

(define-module (arc util features))

(define *config-features* (make-hash-table))

(define *provided-features* (make-hash-table))

(define-syntax-rule (define-feature name body ...)
  "Define a feature, called NAME, that runs BODY when loaded.

Under the hood, BODY is packaged into a new, anonymous procedure.
This new procedure is considered this feature's 'loader'."
  (hashq-set! *config-features*
              'name
              (lambda () body ...)))
(export define-feature)

(define-syntax-rule (define-feature-stub name)
  "Define a stub feature called NAME.
Stub features don't have a loader, so they must be manually provided."
  (hashq-set! *config-features* 'name #f))
(export define-feature-stub)

(define-public (feat-provide feature)
  "Mark FEATURE as provided.
This does not run a feature's associated loader."
  (hashq-set! *provided-features* feature #t))

(define-public (feat-require feature)
  "Require FEATURE, loading it if needed.
Specifically, this will call a feature's loader if it hasn't already been provided.

As stub features lack a loader, this will error when trying to load them."
  (let ((handle (hashq-get-handle *config-features* feature)))
    (unless handle
      (error (format #f "Attempted to require the non-existent feature '~a'" feature)))
      
    (unless (hashq-ref *provided-features* feature)
      (let ((loader (cdr handle)))
        (if (procedure? loader)
            (loader)
            (error (format #f "Stub feature '~a' is not provided" feature))))))

  (feat-provide feature))

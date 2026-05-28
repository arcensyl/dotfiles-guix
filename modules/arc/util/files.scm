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

(define-module (arc util files)
  #:use-module (gnu)
  #:use-module (gnu home services)
  #:use-module (guix records)
  #:use-module (guix gexp)
  #:use-module (arc util misc))

;; A <merged-file-block> is a simple wrapper around a file-like object.
;; These blocks are designed to be assembled into files via 'merged-file'.
(define-record-type* <merged-file-block>
  merged-file-block make-merged-file-block
  merged-file-block?

  ;; The file-like object stored inside this block.
  ;; These are what will actually be combined when generating a merged file.
  (content merged-file-block-content)

  ;; The priority of this block, which defaults to 50.
  ;; This is used to determine the order of blocks within a merged file.
  ;; The higher a block's priority is, the more likely it is to be near the front of the file.
  (priority merged-file-block-priority
            (default 50)))
(export merged-file-block
        make-merged-file-block
        merged-file-block?
        merged-file-block-content
        merged-file-block-priority)

(define* (file->blocks file #:optional (priority 50))
  "Turn FILE into a list of one <merged-file-block> record.
The block will also be assigned PRIORITY, which defaults to 50."
  (list (merged-file-block
         (content file)
         (priority priority))))
(export file->blocks)

(define (path->merged-name path)
  "Given a target PATH, generate a name suitable for a merged file in the store."
  (string-append "merged-" (basename path)))

(define-public (merged-file name blocks)
  "Generate a file, called NAME, by merging the content of BLOCKS.
Each block, in BLOCKS, should be a <merged-file-block> record."
  (let* ((sorted-blocks (sort-list blocks
                                   (lambda (b1 b2)
                                     (> (merged-file-block-priority b1)      ; We sort the list in reverse here.
                                        (merged-file-block-priority b2)))))  ; Higher-priority blocks should be first.
         (files (map merged-file-block-content sorted-blocks)))
    (computed-file name
                   #~(begin
                       (use-modules (ice-9 binary-ports))

                       ;; TODO: Can we use 'sendfile' here?
                       
                       (define (copy-port in out)
                         (let loop ()
                           (let ((bv (get-bytevector-some in)))
                             (unless (eof-object? bv)
                               (put-bytevector out bv)
                               (loop)))))
                       
                       (call-with-output-file #$output
                         (lambda (out)
                           (for-each
                            (lambda (file)
                              (call-with-input-file file
                                (lambda (in) (copy-port in out))))
                            '#$files)))))))

(define (store-blocks! table path blocks)
  "Store BLOCKS under PATH in TABLE."
  (let ((prev (hash-ref table path)))
    (hash-set! table path
               (if prev (append prev blocks) blocks))))

(define-public home-merge-files-service-type
  (service-type
   (name 'home-merge-files)
   (description "Home service to create merged files from blocks.")

   (default-value '())

   ;; Values are threaded through this service in a somewhat unusual way.
   ;; We create a hash map when composing our extensions together.
   ;; Next, we map this service's config into this hash map.
   ;; Finally, this hash map becomes the new value of the config.
   
   (extensions
	(list
	 (service-extension home-files-service-type
                        (lambda (table)
                          (hash-map->list (lambda (path blocks)
                                            (list path
                                                  (merged-file (path->merged-name path)
                                                               blocks)))
                                          table)))))
   
   (compose
    (lambda (extensions)
      (let ((table (make-hash-table)))
        (for-each (lambda (ext)
                    (for-each (lambda (e)
                                (store-blocks! table (car e) (cdr e)))
                              ext))
                  extensions)
        table)))
   
   (extend
    (lambda (config table)
      (for-each (lambda (e) (store-blocks! table (car e) (cdr e)))
                config)
      table))))

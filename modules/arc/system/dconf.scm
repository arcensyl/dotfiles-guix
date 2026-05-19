;;; Copyright © 2024 Michael Atlas
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

(define-module (arc system dconf)
  #:use-module (srfi srfi-1)
  #:use-module (gnu packages gnome) 
  #:use-module (gnu home services)
  #:use-module (guix derivations)
  #:use-module (guix gexp)
  #:use-module (guix store))

;; This was mostly lifted from Michael Atlas's configuration: https://git.sr.ht/~michal_atlas/guix-channel
;; That configuration is licensed under GPLv3, which matches the licensing of my own.

;; TODO: Write your own implementation for configuring Dconf.

(define (dconf-load-gexp settings)
  #~(begin
      (use-modules (ice-9 popen))
      
      (define (alist-value-print value)
        (define (list-vals lv) (string-join (map alist-value-print lv) ", "))
        ((@ (ice-9 match) match) value
         [#t "true"]
         [#f "false"]
         [(? string? str) (format #f "'~a'" str)]
         [(entries ...)
          (format #f "(~a)" (list-vals entries))]
         [#(entries ...)
          (format #f "[~a]" (list-vals entries))]
         [v (format #f "~a" v)]))
      
      (define (alist->ini al)
        (string-concatenate
         (map
          ((@ (ice-9 match) match-lambda)
           [(top-level-path entries ...)
            (format #f "[~a]~%~a~%" top-level-path
	                (string-concatenate
		             (map
		              ((@ (ice-9 match) match-lambda)
		               [(var value)
		                (format #f "~a=~a~%" var (alist-value-print value))])
		              entries)))]) al)))
      
      (let ([dc-pipe (open-pipe* OPEN_WRITE #$(file-append dconf "/bin/dconf") "load" "/")])
	    (display (alist->ini #$settings) dc-pipe))))

(define-public home-dconf-load-service-type
  (service-type
   (name 'dconf-load-service)
   (description "Loads an alist of INI Dconf entries on activation.")

   (default-value '())
  
   (extensions
	(list
	 (service-extension
	  home-activation-service-type
	  dconf-load-gexp)))
   
   (compose concatenate)
   (extend append)))

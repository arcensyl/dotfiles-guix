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

(define-module (my system shells)
  #:use-module (ice-9 match)
  #:use-module (gnu)
  #:use-module (gnu home services)
  #:use-module (gnu home services shells)
  #:use-module (guix records)
  #:use-module (my core)
  #:use-module (my utils features)
  #:use-module (my utils defer))

(define env-var-queue (make-hash-table))
(define shell-alias-queue (make-hash-table))
(define shell-command-queues (make-hash-table))
(define login-shell-command-queues (make-hash-table))

(define-public (provide-env-var variable value)
  (unless (and (string? variable) (string? value))
    (error "Both an environment variable and its value must be a string"))
  (hash-set! env-var-queue variable value))

(define* (provide-env-var-segment variable segment #:key base (separator ":"))
  (unless (and (string? variable)
               (string? segment)
               (or (string? base) (eq? base #f))
               (string? separator))
    (error "All arguments of 'provide-env-var-segment' must be strings"))

  (let* ((prev-val (hash-ref env-var-queue variable))
         (actual-base (or prev-val base (string-append "$" variable)))
         (value (string-append segment separator actual-base)))
    (hash-set! env-var-queue variable value)))
(export provide-env-var-segment)

(define-public (provide-shell-alias alias command)
  (unless (and (string? alias) (string? command))
    (error "Both arguments of 'provide-shell-alias' must be strings"))

  (hash-set! shell-alias-queue alias command))

(define* (run-on-shell-start command #:key (where #t))
  (unless (string? command)
    (error "COMMAND, passed to 'run-on-shell-start', must be a string"))

  (unless (or (symbol? where) (eq? where #t))
    (error "WHERE, passed to 'run-on-shell-start', must be a symbol or #t"))

  (let ((queue (or (hash-ref shell-command-queues where) '())))
    (hash-set! shell-command-queues where (cons (string-append command "\n") queue))))
(export run-on-shell-start)

(define* (run-on-login-shell-start command #:key (where #t))
  (unless (string? command)
    (error "COMMAND, passed to 'run-on-login-shell-start', must be a string"))

  (unless (or (symbol? where) (eq? where #t))
    (error "WHERE, passed to 'run-on-login-shell-start', must be a symbol or #t"))

  (let ((queue (or (hash-ref shell-command-queues where) '())))
    (hash-set! login-shell-command-queues where (cons (string-append command "\n") queue))))
(export run-on-login-shell-start)

(define-public (resolve-shell-command-queue shell)
  (unless (symbol? shell)
    (error "SHELL, passed to 'resolve-shell-command-queue', must be a symbol"))

  (let ((general-queue (or (hash-ref shell-command-queues #t) '()))
        (shell-queue (or (hash-ref shell-command-queues shell) '())))
    (string-concatenate
     (append general-queue shell-queue))))

(define-public (resolve-login-shell-command-queue shell)
  (unless (symbol? shell)
    (error "SHELL, passed to 'resolve-login-shell-command-queue', must be a symbol"))

  (let ((general-queue (or (hash-ref login-shell-command-queues #t) '()))
        (shell-queue (or (hash-ref login-shell-command-queues shell) '())))
    (string-concatenate
     (append general-queue shell-queue))))

(define-feature bash
  (defer
    (use-home-service
     (service home-bash-service-type
              (home-bash-configuration
               (guix-defaults? #f)
               
               (bash-profile (list
                              (plain-file "my-bash-login-commands"
                                          (resolve-login-shell-command-queue 'bash))))
               (bashrc (list
                        (plain-file "my-bash-commands"
                                    (resolve-shell-command-queue 'bash))))
               
               (environment-variables (hash-map->list
                                       (lambda (var val) (cons var val))
                                       env-var-queue))
               
               (aliases (hash-map->list
                         (lambda (alias command) (cons alias command))
                         shell-alias-queue)))))))


(define-feature shell
  (match system-shell
    ('bash (feat-require 'bash))
    (sh (error (format #f "Shell '~a' is not supported" sh)))))

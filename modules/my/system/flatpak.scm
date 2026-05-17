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

(define-module (my system flatpak)
  #:use-module (srfi srfi-1)
  #:use-module (ice-9 popen)
  #:use-module (ice-9 textual-ports)
  #:use-module (gnu)
  #:use-module (gnu home)
  #:use-module (gnu home services)
  #:use-module (guix records)
  #:use-module (my core)
  #:use-module (my util features)
  #:use-module (my util defer)
  #:use-module (my util misc)
  #:use-module (my system shells))

(define %default-flatpak-remote-name "flathub")
(define %default-flatpak-remotes '(("flathub" . "https://flathub.org/repo/flathub.flatpakrepo")))

(define-record-type* <home-flatpak-configuration>
  home-flatpak-configuration make-home-flatpak-configuration
  home-flatpak-configuration?

  (package home-flatpak-configuration-package
                   (default (specification->package "flatpak")))
  
  (remotes home-flatpak-configuration-remotes
           (default %default-flatpak-remotes))
  
  (flatpaks home-flatpak-configuration-flatpaks
            (default '()))

  (preserve? home-flatpak-configuration-preserve?
             (default #f)))
(export home-flatpak-configuration)

(define-record-type* <home-flatpak-extension>
  home-flatpak-extension make-home-flatpak-extension
  home-flatpak-extension?

  (remotes home-flatpak-extension-remotes
           (default '()))

  (flatpaks home-flatpak-extension-flatpaks
            (default '())))
(export home-flatpak-extension)

(define-record-type* <flatpak>
  flatpak make-flatpak
  flatpak?

  (id flatpak-id)

  ;; The 'source' field refers to the remote that provides this Flatpak.
  (source flatpak-source
          (default %default-flatpak-remote-name))

  (arch flatpak-arch
        (default ""))

  (branch flatpak-branch
          (default "")))
(export flatpak)

(define (flatpak->ir pkg)
  (cons (flatpak-id pkg)
        (list
         (cons 'source (flatpak-source pkg))
         (cons 'arch (flatpak-arch pkg))
         (cons 'branch (flatpak-branch pkg)))))

(define (home-flatpak-activation config)
  #~(begin
      (use-modules (ice-9 popen)
                   (ice-9 textual-ports)
                   (srfi srfi-1))

      (define flatpak-bin #$(file-append (home-flatpak-configuration-package config)
                                         "/bin/flatpak"))

      ;; Needed for Flatpak to handle SSL/TLS encryption.
      ;; This service assumes this certificate file is present.
      ;; For more information, see this comment in aurtzy's config:
      ;; https://github.com/aurtzy/guix-config/blob/master/modules/my-guix/home/services/package-management.scm#L209
      (setenv "SSL_CERT_FILE" "/etc/ssl/certs/ca-certificates.crt")

      ;; Several of my utility functions are embbeded in this G-expression.
      
      (define* (list->hash-set list #:optional (insert-fn hash-set!) (value #t))
        (let ((table (make-hash-table (length list))))
          (for-each
           (lambda (item)
             (insert-fn table item value))
           list)
          table))
      
      (define* (alist->hash-map alist #:optional (insert-fn hash-set!))
        (let ((table (make-hash-table (length alist))))
          (for-each
           (lambda (pair)
             (insert-fn table (car pair) (cdr pair)))
           alist)
          table))

      ;; This G-expression also had several unique helper functions.
      
      (define* (run-flatpak-command #:rest args)
        (apply invoke flatpak-bin args))

      (define* (run-flatpak-command-with-output #:rest args)
        (let* ((pipe (apply open-pipe* OPEN_READ flatpak-bin args))
               (output (get-string-all pipe)))
          (close-pipe pipe)
          (string-trim-right output #\newline)))

      (define* (run-flatpak-command-and-ignore-errors #:rest args)
        (call-with-port (%make-void-port "w")
          (lambda (port)
            (with-error-to-port port
              (lambda ()
                (apply system* flatpak-bin args))))))

      ;; (define (system-flatpak-remotes)
      ;;   (string-split
      ;;    (run-flatpak-command-with-output "remotes" "--columns=name")
      ;;    #\newline))

      (define (system-flatpak-remotes)
        (let ((output (run-flatpak-command-with-output "remotes" "--columns=name")))
          (if (not (equal? output ""))
              (string-split output #\newline)
              '())))

      ;; (define (system-flatpak-apps)
      ;;   (string-split
      ;;    (run-flatpak-command-with-output "list" "--user" "--app" "--columns=application")
      ;;    #\newline))

      (define (system-flatpaks)
        (let ((output (run-flatpak-command-with-output "list" "--user" "--columns=application")))
          (if (not (equal? output ""))
              (string-split output #\newline)
              '())))

      (define (system-flatpak-apps)
        (let ((output (run-flatpak-command-with-output "list" "--user" "--app" "--columns=application")))
          (if (not (equal? output ""))
              (string-split output #\newline)
              '())))

      (define (simple-flatpak->ref id data)
        (let ((arch (assq-ref data 'arch))
              (branch (assq-ref data 'branch)))
          (string-append id "/" arch "/" branch)))
      
      ;; The actual Flatpak management code begins here.
      
      (let ((preserve? #$(home-flatpak-configuration-preserve? config))
            (prev-flatpaks (list->hash-set (system-flatpaks)))
            (prev-flatpak-apps (list->hash-set (system-flatpak-apps)))
            (new-flatpaks (alist->hash-map '#$(map flatpak->ir (home-flatpak-configuration-flatpaks config))))
            (prev-remotes (system-flatpak-remotes))
            (new-remotes (alist->hash-map '#$(home-flatpak-configuration-remotes config))))
        (format #t "Adding any new Flatpak remotes...~%")
        (hash-for-each
         (lambda (name link)
           (run-flatpak-command "remote-add"
                                "--user"
                                "--if-not-exists"
                                name
                                link))
         new-remotes)

        (format #t "Installing any new Flatpak applications...~%")
        (hash-for-each
         (lambda (app data)
           (unless (hash-get-handle prev-flatpaks app)
             (let ((source (assq-ref data 'source)))
               (when source
                 (run-flatpak-command "install"
                                      "--user"
                                      "--noninteractive"
                                      source
                                      (simple-flatpak->ref app data))))))
         new-flatpaks)
 
        (unless preserve?
          (format #t "Removing any undeclared Flatpak applications...~%")
          (hash-for-each
           (lambda (app _)
             (unless (hash-get-handle new-flatpaks app)
               (run-flatpak-command "remove"
                                    "--user"
                                    "--noninteractive"
                                    app)))
           prev-flatpak-apps)

          (format #t "Removing all unused Flatpak runtimes...~%")
          (run-flatpak-command "remove"
                               "--user"
                               "--noninteractive"
                               "--unused")
 
          (format #t "Removing any undeclared Flatpak remotes...~%")
          (for-each
           (lambda (remote)
             (unless (hash-get-handle new-remotes remote)
               (run-flatpak-command-and-ignore-errors "remote-delete"
                                                      "--force"
                                                      remote)))
           prev-remotes)))))

(define home-flatpak-service-type
  (service-type
   (name 'home-flatpak)
   (description "Home service for managing Flatpak remotes and applications.")

   (default-value (home-flatpak-configuration))
   
   (extensions
    (list
     (service-extension home-profile-service-type
                        (lambda (config)
                          (list
                           (home-flatpak-configuration-package config))))

     (service-extension home-environment-variables-service-type
                        (lambda (_)
                          (list
                           (cons "XDG_DATA_DIRS"
                                 "/var/lib/flatpak/exports/share:$HOME/.local/share/flatpak/exports/share:$XDG_DATA_DIRS"))))
     
     (service-extension home-activation-service-type
                        home-flatpak-activation)))

   (compose
    (lambda (extensions)
      (home-flatpak-extension
       (remotes (concatenate (map home-flatpak-extension-remotes extensions)))
       (flatpaks (concatenate (map home-flatpak-extension-flatpaks extensions))))))

   (extend
    (lambda (config extension)
      (home-flatpak-configuration
       (inherit config)
       
       (remotes (append (home-flatpak-extension-remotes extension)
                        (home-flatpak-configuration-remotes config)))
       
       (flatpaks (append (home-flatpak-extension-flatpaks extension)
                         (home-flatpak-configuration-flatpaks config))))))))
(export home-flatpak-service-type)

(define* (make-flatpakexec-constructor flatpak-with-args #:key command #:allow-other-keys #:rest constructor-args)
  #~(make-forkexec-constructor
     ;; We don't have easy access to the right package, so we search for Flatpak in PATH.
     (list "/usr/bin/env"
           "flatpak"
           "run"
           #$@(if command
                  (list (string-append "--command=\"" command "\""))
                  '())
           #$(car flatpak-with-args)
           #$@(cdr flatpak-with-args))
     #$@constructor-args))
(export make-flatpakexec-constructor)

(define flatpak-queue '())
(define flatpak-remote-queue (make-hash-table))

(define (process-use-flatpak-arg app)
  (cond ((flatpak? app) app)
        ((string? app) (flatpak (id app)))
        (else (error "An item passed to 'use-flatpaks' was not a flatpak or application ID"))))

(define* (use-flatpaks #:rest flatpaks)
  (for-each (lambda (app) (set! flatpak-queue (cons app flatpak-queue)))
            (map process-use-flatpak-arg flatpaks)))
(export use-flatpaks)

(define-public (use-flatpak-remote remote address)
  (hash-set! flatpak-remote-queue remote address))

(define* (provide-flatpak-alias alias flatpak-id #:optional command)
  (if command
      (provide-shell-alias alias (string-append "flatpak run --command=\""
                                                command
                                                "\" "
                                                flatpak-id))
      (provide-shell-alias alias (string-append "flatpak run "
                                                flatpak-id))))
(export provide-flatpak-alias)

(define-feature flatpak
  (use-flatpaks "com.github.tchx84.Flatseal")
  (provide-flatpak-alias "flatseal" "com.github.tchx84.Flatseal")
  
  (defer
    (use-home-service
     (service home-flatpak-service-type
              (home-flatpak-configuration
               (remotes (append (hash-map->alist flatpak-remote-queue)
                                %default-flatpak-remotes))
               (flatpaks flatpak-queue))))))

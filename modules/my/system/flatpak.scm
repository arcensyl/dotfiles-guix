(define-module (my system flatpak)
  #:use-module (ice-9 popen)
  #:use-module (ice-9 textual-ports)
  #:use-module (gnu)
  #:use-module (gnu home)
  #:use-module (gnu home services)
  #:use-module (guix records)
  #:use-module (my core)
  #:use-module (my utils units)
  #:use-module (my utils misc)
  #:use-module (my system shells))

(define %default-flatpak-remote-name "flathub")
(define %default-flatpak-remotes '(("flathub" . "https://flathub.org/repo/flathub.flatpakrepo")))

(define-record-type* <my-home-flatpak-configuration>
  my-home-flatpak-configuration make-my-home-flatpak-configuration
  my-home-flatpak-configuration?

  (package my-home-flatpak-configuration-package
                   (default (specification->package "flatpak")))
  
  (remotes my-home-flatpak-configuration-remotes
           (default %default-flatpak-remotes))
  
  (flatpaks my-home-flatpak-configuration-flatpaks
            (default '()))

  (preserve? my-home-flatpak-configuration-preserve?
             (default #f)))
(export my-home-flatpak-configuration)

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

;; (define (new-flatpak-alist config)
;;   (map
;;    (lambda (pkg)
;;      (cons (flatpak-id pkg) (flatpak-source pkg)))
;;    (my-home-flatpak-configuration-flatpaks config)))

(define (new-flatpak-alist config)
  (map
   (lambda (pkg)
     (cons
      (flatpak-id pkg)
      (list
       (cons 'source (flatpak-source pkg))
       (cons 'arch (flatpak-arch pkg))
       (cons 'branch (flatpak-branch pkg)))))
   (my-home-flatpak-configuration-flatpaks config)))

(define (my-home-flatpak-activation config)
  #~(begin
      (use-modules (ice-9 popen)
                   (ice-9 textual-ports)
                   (srfi srfi-1))

      (define flatpak-bin #$(file-append (my-home-flatpak-configuration-package config)
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
      
      (let ((preserve? #$(my-home-flatpak-configuration-preserve? config))
            (prev-flatpaks (list->hash-set (system-flatpaks)))
            (prev-flatpak-apps (list->hash-set (system-flatpak-apps)))
            (new-flatpaks (alist->hash-map '#$(new-flatpak-alist config)))
            (prev-remotes (system-flatpak-remotes))
            (new-remotes (alist->hash-map '#$(my-home-flatpak-configuration-remotes config))))
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
             (run-flatpak-command "install"
                                  "--user"
                                  "--noninteractive"
                                  (assq-ref data 'source)
                                  (simple-flatpak->ref app data))))
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

(define my-home-flatpak-service-type
  (service-type
   (name 'my-home-flatpak)
   (description "Home service for managing Flatpak remotes and applications.")

   (default-value (my-home-flatpak-configuration))
   
   (extensions
    (list
     (service-extension home-profile-service-type
                        (lambda (config)
                          (list
                           (my-home-flatpak-configuration-package config))))

     (service-extension home-environment-variables-service-type
                        (lambda (_)
                          (list
                           (cons "XDG_DATA_DIRS"
                                 "/var/lib/flatpak/exports/share:$HOME/.local/share/flatpak/exports/share:$XDG_DATA_DIRS"))))
     
     (service-extension home-activation-service-type
                        my-home-flatpak-activation)))))
(export my-home-flatpak-service-type)

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

(define-public (provide-flatpak-alias alias flatpak-id)
  (provide-shell-alias alias (string-append "flatpak run " flatpak-id)))

(define-unit ((system flatpak))
  (use-flatpaks "com.github.tchx84.Flatseal")
  (provide-flatpak-alias "flatseal" "com.github.tchx84.Flatseal")
  
  (eval-after-units
   (use-home-service
    (service my-home-flatpak-service-type
             (my-home-flatpak-configuration
              (remotes (append (hash-map->alist flatpak-remote-queue)
                               %default-flatpak-remotes))
              (flatpaks flatpak-queue))))))

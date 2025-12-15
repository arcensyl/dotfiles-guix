(define-module (my apps editors emacs)
  #:use-module (gnu)
  #:use-module (gnu services shepherd)
  #:use-module (gnu packages emacs)
  #:use-module (gnu home)
  #:use-module (gnu home services)
  #:use-module (gnu home services shepherd)
  #:use-module (guix records)
  #:use-module (my core)
  #:use-module (my utils units)
  #:use-module (my system shells))

(define-record-type* <home-emacs-configuration>
  home-emacs-configuration make-home-emacs-configuration
  home-emacs-configuration?

  (package home-emacs-configuration-package
           (default emacs))

  (daemon? home-emacs-configuration-daemon?
           (default #f)))

(define (home-emacs-shepherd-service config)
  (shepherd-service
   (documentation "Run Emacs, the hackable text editor, as a daemon.")
   (provision '(emacs))

   (start #~(make-forkexec-constructor
             (list #$(file-append (home-emacs-configuration-package config)
                                  "/bin/emacs")
                   "--fg-daemon")))

   (stop #~(make-kill-destructor))))

(define home-emacs-service-type
  (service-type
   (name 'home-emacs)
   (description "Home service to install Emacs, and possibly set up its daemon.")

   (default-value (home-emacs-configuration))
   
   (extensions
    (list
     (service-extension home-profile-service-type
                        (lambda (config)
                          (list
                           (home-emacs-configuration-package config))))

     (service-extension home-shepherd-service-type
                        (lambda (config)
                          (if (home-emacs-configuration-daemon? config)
                              (list
                               (home-emacs-shepherd-service config))
                              '())))))))
(export home-emacs-service-type)

(define-unit* ((apps editors emacs) #:key daemon?)
  (use-home-service
   (service home-emacs-service-type
            (home-emacs-configuration
             (package (if (using-unit? '(system wayland)) emacs-pgtk emacs))
             (daemon? daemon?))))

  (provide-shell-alias "emacs" "emacsclient -c"))

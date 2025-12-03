(define-module (my suites secrets)
  #:use-module (gnu)
  #:use-module (gnu home services gnupg)
  #:use-module (my core)
  #:use-module (my utils units))

(define-unit ((suites secrets))
  (use-home-packages "password-store")

  (use-home-service
   (service home-gpg-agent-service-type
            (home-gpg-agent-configuration
             (pinentry-program (file-append (specification->package "pinentry-qt")
                                            "/bin/pinentry"))
             (ssh-support? #t)))))

;; The 'core' module is literally the heart of my entire configuration.
;; It provides tools to set up a minimal system, and then extend it with extra services and packages.

(define-module (my core))

(define-public hostname
  (or (getenv "GUIX_HOSTNAME")
      (error "Environment variable GUIX_HOSTNAME is not set")))


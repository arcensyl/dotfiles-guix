;; Welcome to Arc's Guix System configuration.
;; This is the entry point for my entire configuration.
;; It is responsible for ensuring my modules are available, loading host-specific files, and building the final `operating-system` record.
;; This file should be kept as minimal as possible, with machine-specific settings being specified in their relevant host directory.

;; Before doing anything else, we need to ensure Guix can find my modules.
(add-to-load-path "./modules")

(use-modules (ice-9 format)
             (my core))

(define host-config-file (string-append "./hosts/" system-name "/config.scm"))
(define host-hardware-file (string-append "./hosts/" system-name "/hardware.scm"))

(unless (file-exists? host-config-file)
  (error (format #f "No 'config.scm' file found for the host '~a'." system-name)))

(unless (file-exists? host-hardware-file)
  (error (format #f "No 'hardware.scm' file found for the host '~a'." system-name)))

(load host-config-file)
(load host-hardware-file)

(make-operating-system)

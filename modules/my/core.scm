;; The 'core' module is literally the heart of my entire configuration.
;; It provides tools to set up a minimal system, and then extend it with extra services and packages.

(define-module (my core)
  #:use-module (gnu)
  #:use-module (gnu services guix)
  #:use-module (gnu services desktop)
  #:use-module (gnu services xorg)
  #:use-module (gnu services sound)
  #:use-module (gnu home)
  #:use-module (guix)
  #:use-module (nongnu packages linux)
  #:use-module (my utils units))

;; Settings for this system.

(define-public system-name
  (or (getenv "GUIX_HOSTNAME")
      (error "Environment variable GUIX_HOSTNAME is not set")))

(define-public system-locale "en_US.utf8")
(define-public system-timezone "UTC")
(define-public system-keyboard-layout (keyboard-layout "us"))

;; Settings for the main user, or "master", of this system.
(define-public master-name "master")
(define-public master-comment "Master User")
(define-public master-home-directory "/home/master")

(define package-queue (make-hash-table))
(define home-package-queue (make-hash-table))

(define service-queue '())
(define home-service-queue '())

(define file-system-queue '())
(define swap-space-queue '())

(define (process-use-package-arg package)
  (cond ((package? package) package)
        ((string? package) (specification->package package))
        (else (error "An item passed to 'use-packages' or 'use-home-packages' was not a package or specification"))))

(define* (use-packages #:rest packages)
  (for-each (lambda (pkg) (hash-set! package-queue pkg #t))
            (map process-use-package-arg packages)))
(export use-packages)

(define* (use-home-packages #:rest packages)
  (for-each (lambda (pkg) (hash-set! home-package-queue pkg #t))
            (map process-use-package-arg packages)))
(export use-home-packages)

(define-public (use-service service)
  (unless (service? service)
    (error "Item passed to 'use-service' was not a service"))
  (set! service-queue (cons service service-queue)))

(define-public (use-home-service service)
  (unless (service? service)
    (error "Item passed to 'use-home-service' was not a service"))
  (set! home-service-queue (cons service home-service-queue)))

(define-public (use-file-system file-system)
  (unless (file-system? file-system)
    (error "Item passed to 'use-file-system' was not a file system"))
  (set! file-system-queue (cons file-system file-system-queue)))

(define-public (use-swap-space swap-space)
  (unless (swap-space? swap-space)
    (error "Item passed to 'use-swap-space' was not swap space"))
  (set! swap-space-queue (cons swap-space swap-space-queue)))

(define-public (make-operating-system)
  (use-service
   (service guix-home-service-type
            (list (list master-name
                        (home-environment
                         (packages (hash-map->list (lambda (key _) key) home-package-queue))
                         (services (append home-service-queue %base-home-services)))))))
  
  (operating-system
   (kernel linux)
   (firmware (list linux-firmware))

   (locale system-locale)
   (timezone system-timezone)
   (keyboard-layout system-keyboard-layout)
   (host-name system-name)

   (users (cons* (user-account
                  (name master-name)
                  (comment master-comment)
                  (group "users")
                  (home-directory master-home-directory)
                  (supplementary-groups '("wheel" "netdev" "audio" "video")))
                 %base-user-accounts))


   (services
    (append service-queue
            (modify-services %desktop-services
                             (delete gdm-service-type)
                             (delete pulseaudio-service-type))))

   (packages
    (append (hash-map->list (lambda (key _) key) package-queue)
            %base-packages))

   (bootloader (bootloader-configuration
                (bootloader grub-efi-bootloader)
                (targets (list "/boot/efi"))
                (keyboard-layout system-keyboard-layout)))

   (file-systems (append file-system-queue %base-file-systems))

   (swap-devices swap-space-queue)))

(define (apply-core-unit)
  (use-packages
   ;; Libraries
   "ncurses"

   ;; CLI Essentials
   "fastfetch"

   ;; Config-related Tools
   "git"
   "just"))

(register-unit 'core apply-core-unit)

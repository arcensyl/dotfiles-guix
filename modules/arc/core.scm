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

;; The 'core' module is literally the heart of my entire configuration.
;; It provides tools to set up a minimal system, and then extend it with extra services and packages.

(define-module (arc core)
  #:use-module (ice-9 match)
  #:use-module (gnu)
  #:use-module (gnu services guix)
  #:use-module (gnu services desktop)
  #:use-module (gnu services xorg)
  #:use-module (gnu services sound)
  #:use-module (gnu home)
  #:use-module (gnu home services)
  #:use-module (guix)
  #:use-module (nongnu packages linux)
  #:use-module (arc util features)
  #:use-module (arc util files)
  #:use-module (arc util defer)
  #:use-module (arc util misc)
  #:use-module (arc system hardware)
  #:use-module (arc system shells)
  #:use-module (arc system nix)
  #:use-module (arc system flatpak))

;; Settings for this system.

(define-public system-name (getenv "GUIX_HOSTNAME"))

(define-public system-type 'server)
(define-public system-locale "en_US.utf8")
(define-public system-timezone "UTC")
(define-public system-keyboard-layout (keyboard-layout "us"))
(define-public system-shell 'bash)

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

(define substitute-server-queue '())
(define substitute-key-queue '())

(define activation-counter 0)
(define home-activation-counter 0)

(define (process-use-package-arg package)
  (cond ((package? package) package)
        ((list? package) package)
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

(define-public (use-substitute-server address)
  (unless (string? address)
    (error "ADDRESS, passed to 'use-substitute-server', must be a string"))
  (set! substitute-server-queue (cons address substitute-server-queue)))

(define-public (use-substitute-key key)
  (unless (file-like? key)
    (error "KEY, passed to 'use-substitute-key', must be a file-like object"))
  (set! substitute-key-queue (cons key substitute-key-queue)))

(define-public (use-extra-special-file name file)
  (use-service (extra-special-file name file)))

(define-public (run-on-activation gexp)
  "Run GEXP at the system's \"activation time\"."
  (set! activation-counter (1+ activation-counter))
  
  (let* ((raw-service-name (string-append "anonymous-activation-"
                                         (number->string activation-counter)))
        (service-name (string->symbol raw-service-name)))
    (use-service
     (simple-service service-name
                     activation-service-type
                     gexp))))

(define-public (run-on-home-activation gexp)
  "Run GEXP at the home environment's \"activation time\"."
  (set! home-activation-counter (1+ home-activation-counter))
  
  (let* ((raw-service-name (string-append "anonymous-home-activation-"
                                         (number->string home-activation-counter)))
        (service-name (string->symbol raw-service-name)))
    (use-home-service
     (simple-service service-name
                     home-activation-service-type
                     gexp))))

;; TODO: Consider giving servers their own operating system constructor.

(define-public (make-system)
  (use-service
   (service guix-home-service-type
            (list (list master-name
                        (home-environment
                         (packages (hash-map->list (lambda (key _) key) home-package-queue))
                         (services (append home-service-queue %base-home-services)))))))
  
  (use-home-service (service home-merge-files-service-type))

  (match system-type
    ('server (make-basic-system))
    ((or 'desktop 'laptop) (make-desktop-system))
    ('flash (make-flash-system))
    (_ (errorf "System type '~a' is not supported" system-type))))

(define (make-basic-system)
  (operating-system
   (kernel linux)
   (firmware (list linux-firmware))

   (host-name (or system-name "guix"))
   (locale system-locale)
   (timezone system-timezone)
   (keyboard-layout system-keyboard-layout)

   (users (cons* (user-account
                  (name master-name)
                  (password (crypt "111" "guix-salt"))
                  (comment master-comment)
                  (home-directory master-home-directory)
                  (group "users")
                  (supplementary-groups '("wheel" "netdev" "audio" "video")))
                 %base-user-accounts))

   (services
    (append service-queue
            (modify-services %base-services
                             (guix-service-type config => (guix-configuration
                                                           (inherit config)
                                                           (substitute-urls
                                                            (append substitute-server-queue
                                                                    %default-substitute-urls))
                                                           (authorized-keys
                                                            (append substitute-key-queue
                                                                    %default-authorized-guix-keys)))))))
   
   (packages
    (append (hash-map->list (lambda (key _) key) package-queue)
            %base-packages))

   (bootloader (bootloader-configuration
                (bootloader grub-efi-bootloader)
                (targets (list "/boot/efi"))
                (keyboard-layout system-keyboard-layout)))

   (file-systems (append file-system-queue %base-file-systems))

   (swap-devices swap-space-queue)))

(define (make-desktop-system)
  (operating-system
   (inherit (make-basic-system))

   (firmware (list linux-firmware
                   sof-firmware))

   (services
    (append service-queue
            (modify-services %desktop-services
                             (delete gdm-service-type)
                             (delete pulseaudio-service-type)

                             (guix-service-type config => (guix-configuration
                                                           (inherit config)
                                                           (substitute-urls
                                                            (append substitute-server-queue
                                                                    %default-substitute-urls))
                                                           (authorized-keys
                                                            (append substitute-key-queue
                                                                    %default-authorized-guix-keys)))))))))

(define (make-flash-system)
  (operating-system
   (inherit (make-desktop-system))

   ;; NOTE: Password authentication for 'sudo' is disabled on flash systems.
   ;; This was decided because many operations from an installer/rescue USB need root access.
   ;; Flash systems should be considered insecure, and they should only be used when needed.
   
   (sudoers-file
    (plain-file "flash-sudoers"
                "root ALL=(ALL) ALL\n%wheel ALL=(ALL) NOPASSWD: ALL\n"))

   (bootloader (bootloader-configuration
                (bootloader grub-efi-removable-bootloader)
                (targets (list "/boot/efi"))
                (keyboard-layout system-keyboard-layout)))
   
   (file-systems (cons* (file-system
                         (mount-point "/")
                         (device (file-system-label "guix-flash"))
                         (type "ext4"))
                        %base-file-systems))

   (swap-devices '())))

(define-feature core
  (feat-require 'nix)
  (feat-require 'shell)

  (feat-require 'auto-brightness-dyn)
    
  (use-substitute-server "https://substitutes.nonguix.org")
  (use-substitute-key (local-file "../../keys/nonguix.pub"))

  (defer (provide-env-var "GUIX_HOSTNAME" system-name))
  (provide-env-var-segment "PATH" "$HOME/.dotfiles/guix/scripts")

  (provide-shell-alias "gx" "guix")
  
  (use-packages
   ;; Libraries and Toolchains
   "gcc-toolchain"
   "perl"
   "ncurses"

   ;; CLI Essentials
   "fastfetch"
   "openssh"
   "curl"

   ;; Config-related Tools
   "git"
   "just")

  (defer
    (when (eq? system-type 'laptop)
      (use-packages
       "brightnessctl"))))

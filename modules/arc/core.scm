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
  #:use-module (arc system shells)
  #:use-module (arc system nix)
  #:use-module (arc system flatpak))

;; Settings for this system.

(define-public system-name
  (or (getenv "GUIX_HOSTNAME")
      (error "Environment variable GUIX_HOSTNAME is not set")))

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

(define-public (use-substitute-server address)
  (unless (string? address)
    (error "ADDRESS, passed to 'use-substitute-server', must be a string"))
  (set! substitute-server-queue (cons address substitute-server-queue)))

(define-public (use-substitute-key key)
  (unless (file-like? key)
    (error "KEY, passed to 'use-substitute-key', must be a file-like object"))
  (set! substitute-key-queue (cons key substitute-key-queue)))

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
                             (delete pulseaudio-service-type)

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

(define-feature core
  (feat-require 'shell)
  (feat-require 'flatpak)
  (feat-require 'nix)
  
  (use-substitute-server "https://substitutes.nonguix.org")
  (use-substitute-key (local-file "../../gen/auth/nonguix.pub"))
  
  (provide-env-var "GUIX_HOSTNAME" system-name)
  (provide-env-var-segment "PATH" "$HOME/.dotfiles/guix/scripts")

  (provide-shell-alias "gx" "guix")
  
  (use-packages
   ;; Libraries and Toolchains
   "gcc-toolchain"
   "ncurses"

   ;; CLI Essentials
   "fastfetch"
   "openssh"

   ;; Config-related Tools
   "git"
   "just"))

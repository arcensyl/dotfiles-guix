;; This file is required to boot your Guix system.
;; Do NOT edit or delete this file's contents.

(use-modules (gnu)
             (arc core))

(use-file-system
  (file-system
    (device (file-system-label "guix-boot"))
    (mount-point "/boot/efi")
    (type "vfat")))

(use-file-system
  (file-system
    (device (file-system-label "guix-root"))
    (mount-point "/")
    (type "ext4")))

(use-swap-space
  (swap-space
    (target (file-system-label "guix-swap"))))

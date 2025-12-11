(define-module (my de hypr)
  #:use-module (gnu)
  #:use-module (my core)
  #:use-module (my utils units)
  #:use-module (my system graphics))

;; TODO: Write a custom home service for configuring Hyprland.

(define-unit ((de hypr))
  (use-home-packages "hyprland"))

(hook-unit '(de hypr) '(system wayland))

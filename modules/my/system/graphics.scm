(define-module (my system graphics)
  #:use-module (gnu)
  #:use-module (my core)
  #:use-module (my utils units))

(define-unit ((system wayland))
  (use-home-packages
   ;; Wayland-specific Tools
   "wl-clipboard"

   ;; Tools useful across WMs
   "rofi"))

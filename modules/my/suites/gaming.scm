(define-module (my suites gaming)
  #:use-module (gnu)
  #:use-module (my core)
  #:use-module (my utils units)
  #:use-module (my system flatpak))

(define-unit ((suites gaming))
  (use-home-packages
   ;; Game-related Utilities
   "protonup"
   "mangohud"

   ;; Game Stores and Launchers
   "steam"
   "heroic")

  (use-flatpaks
   ;; Game Stores and Launchers
   "org.prismlauncher.PrismLauncher")

  (provide-flatpak-alias "prism-launcher"
                         "org.prismlauncher.PrismLauncher"))

(hook-unit '(suites gaming) '(system flatpak))

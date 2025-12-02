(define-module (my suites chat)
  #:use-module (gnu)
  #:use-module (my core)
  #:use-module (my utils units)
  #:use-module (my system flatpak))

(define-unit ((suites chat))
  (use-home-packages "mumble")
  (use-flatpaks "dev.vencord.Vesktop")
  
  (provide-flatpak-alias "vesktop" "dev.vencord.Vesktop"))

(define-module (my system audio)
  #:use-module (gnu)
  #:use-module (gnu home services desktop)
  #:use-module (gnu home services sound)
  #:use-module (my core)
  #:use-module (my utils units))

(define-unit ((system audio))
  (use-home-service (service home-dbus-service-type))
  (use-home-service (service home-pipewire-service-type))

  (use-home-packages "wireplumber" "pulseaudio"))

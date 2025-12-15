(define-module (my system lang input)
  #:use-module (gnu)
  #:use-module (gnu services shepherd)
  #:use-module (gnu packages fcitx5)
  #:use-module (gnu home)
  #:use-module (gnu home services)
  #:use-module (gnu home services shepherd)
  #:use-module (my core)
  #:use-module (my utils units)
  #:use-module (my system flatpak))

;; HACK: This entire setup is cursed.
;; Because I use Mozc for my Japanese IME, I need to use the Flatpak version of Fcitx.
;; This surprisingly works fine, provided Fcitx's native packages are installed too.

;; TODO: When I find or write a derivation for Mozc, update this to just use the native version of Fcitx.

;; TODO: Investigate allowing Fcitx to be configured with my home service.

(define home-fcitx-shepherd-service
  (shepherd-service
   (documentation "Run Fcitx, an input method framework.")
   (provision '(fcitx))
   (requirement '(graphical-session))
   
   (start #~(make-forkexec-constructor
             (list "/usr/bin/env"
                   "flatpak"
                   "run"
                   "org.fcitx.Fcitx5")
             #:environment-variables (cons* (string-append "WAYLAND_DISPLAY="
                                                          #$(or (getenv "WAYLAND_DISPLAY")
                                                                "wayland-1"))
                                            (default-environment-variables))))
   
   (stop #~(make-kill-destructor))))


(define home-fcitx-service-type
  (service-type
   (name 'home-fcitx)
   (description "Home service for running the Fcitx input method framework.")

   (default-value '())

   (extensions
    (list
     (service-extension home-profile-service-type
                        (lambda (_)
                          (list fcitx5
                                fcitx5-gtk
                                fcitx5-qt
                                fcitx5-configtool)))

     (service-extension my-home-flatpak-service-type
                        (lambda (_)
                          (my-home-flatpak-extension
                           (flatpaks (list (flatpak (id "org.fcitx.Fcitx5")))))))
     
     (service-extension home-environment-variables-service-type
                        (lambda (_)
                          '(("GTK_IM_MODULE" . "fcitx")
                            ("QT_IM_MODULE" . "fcitx")
                            ("XMODIFIERS" . "@im=fcitx"))))

     (service-extension home-shepherd-service-type
                        (lambda (_)
                          (list home-fcitx-shepherd-service)))))))
(export home-fcitx-service-type)

(define-unit ((system lang input))
  (use-home-service
   (service home-fcitx-service-type)))

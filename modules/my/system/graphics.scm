(define-module (my system graphics)
  #:use-module (gnu)
  #:use-module (gnu services shepherd)
  #:use-module (gnu home services shepherd)
  #:use-module (my core)
  #:use-module (my utils units))

(define home-wayland-shepherd-service
  (shepherd-service
   (documentation "Dummy service indicating a Wayland session has started.")
   (provision '(wayland graphical-session))

   ;; HACK: Because of how Shepherd handles requirements, it will auto-start this service when another needs it.
   ;; This means that this service needs to block until it knows Wayland is running.
   ;; It does this by repeatdly checking for the existence of Wayland's socket.
   ;; Until that socket is created, this service will appear to be perpetually 'starting'.
   (start #~(lambda ()
              (let* ((runtime-path (or (getenv "XDG_RUNTIME_DIR")
                                       (string-append "/run/user/" (number->string (getuid)))))
                     (socket-path (string-append runtime-path "/wayland-1")))
                (let loop ()
                  (if (file-exists? socket-path)
                      #t
                      (begin
                        (sleep 1)
                        (loop)))))))
   
   (stop #~(lambda () #t))

   (auto-start? #f)
   (one-shot? #t)))

(define-unit ((system wayland))
  (use-home-packages
   ;; Wayland-specific Tools
   "wl-clipboard"

   ;; Tools useful across WMs
   "rofi")

  (use-home-service
   (simple-service 'register-home-wayland-shepherd-service
                   home-shepherd-service-type
                   (list home-wayland-shepherd-service))))

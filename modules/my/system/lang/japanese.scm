(define-module (my system lang japanese)
  #:use-module (gnu)
  #:use-module (my core)
  #:use-module (my utils units)
  #:use-module (my system flatpak)
  #:use-module (my system lang input))

;; NOTE: To use Mozc, you will need to manually enable it in Fcitx's configuration.
;; If I add configuration support to my Fcitx service, I'll make this automatic.

;; TODO: Figure out how to get Emacs's 'mozc' package working with my bizarre setup.

(define-unit ((system lang japanese))
  (use-flatpaks "org.fcitx.Fcitx5.Addon.Mozc"))

(hook-unit '(system lang japanese) '(system lang input))

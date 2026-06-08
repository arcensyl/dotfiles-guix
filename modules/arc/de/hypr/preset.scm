(define-module (arc de hypr preset)
  #:use-module (arc de hypr)
  #:use-module (arc util features)
  #:use-module (arc util keys)
  #:use-module (arc util misc))

;; This feature provides many of my preferred settings for Hyprland.
;; As this is obviously very optionated, you may only want some of my settings.
;; If so, look into my individual 'hp-*' features.
(define-feature hypr-preset
  (feat-require 'hyprland)

  (feat-require 'hp-layout)
  (feat-require 'hp-visuals)
  (feat-require 'hp-keybinds))

(define-feature hp-layout
  (use-hypr-options
   '((general . ((layout . "dwindle")))
     
     (dwindle . ((preserve-split? . #t)
                 (smart-split? .    #t))))))

(define-feature hp-visuals
  (use-hypr-options
   '((general . ((gaps-in .             10)
                 (gaps-out .            20)
                 (border-size .         2)
                 
                 (col . ((inactive-border . "#2F2F2F")
                         (active-border .   "#B9B9B9")))))
     
     (decoration . ((rounding . 10)
                    
                    (blur . ((enabled? .   #t)
                             (size .       3)
                             (passes .     3)
                             (vibrancy .   0.17)))
                    
                    (shadow . ((enabled? .     #t)
                               (range .        16)
                               (render-power . 5)
                               (color .        "#00000059")))))
     
     (group . ((col . ((border-inactive . "#2F2F2F")
                       (border-active . "#B9B9B9")))
               
               (groupbar . ((gradients? .   #f)
                            
                            (col . ((inactive . "#2F2F2F")
                                    (active .   "#B9B9B9"))))))))))

(define-feature hp-keybinds
  ;; Window Navigation
  (bind-hypr (kb "Z-<up>") '(focus ((direction . "up"))))
  (bind-hypr (kb "Z-<left>") '(focus ((direction . "left"))))
  (bind-hypr (kb "Z-<right>") '(focus ((direction . "right"))))
  (bind-hypr (kb "Z-<down>") '(focus ((direction . "down"))))

  ;; Window Movement
  (bind-hypr (kb "Z-S-<up>") '(window.move ((direction . "up"))))
  (bind-hypr (kb "Z-S-<left>") '(window.move ((direction . "left"))))
  (bind-hypr (kb "Z-S-<right>") '(window.move ((direction . "right"))))
  (bind-hypr (kb "Z-S-<down>") '(window.move ((direction . "down"))))

  (bind-hypr (kb "Z-C-<up>")
             '(window.move ((direction . "up") (group-aware? . #t))))
  
  (bind-hypr (kb "Z-C-<left>")
             '(window.move ((direction . "left") (group-aware? . #t))))
  
  (bind-hypr (kb "Z-C-<right>")
             '(window.move ((direction . "right") (group-aware? . #t))))
  
  (bind-hypr (kb "Z-C-<down>")
             '(window.move ((direction . "down") (group-aware? . #t))))

  ;; TODO: Add mouse binds for moving and resizing windows.
  
  ;; Workspace Navigation and Movement
  (let loop ((idx 1))
    (let ((key (number->string (modulo idx 10)))) ; Key '0' is used for 10
      (bind-hypr (keybind
                  (key key)
                  (modifiers '(super)))
                 `(focus ((workspace . ,idx))))
    
      (bind-hypr (keybind
                  (key key)
                  (modifiers '(super shift)))
                 `(window.move ((workspace . ,idx)))))
    
    (unless (>= idx 10)
      (loop (1+ idx))))

  ;; Window Actions
  (bind-hypr (kb "Z-c") '(window.close))
  (bind-hypr (kb "Z-k") '(window.kill))
  (bind-hypr (kb "Z-f") '(window.fullscreen ((action . "toggle"))))
  (bind-hypr (kb "Z-v") '(window.float ((action . "toggle"))))

  ;; Groups
  (bind-hypr (kb "Z-g") '(group.toggle))
  (bind-hypr (kb "Z-,") '(group.prev))
  (bind-hypr (kb "Z-.") '(group.next))
  (bind-hypr (kb "Z-<page_up>") '(group.prev))
  (bind-hypr (kb "Z-<page_down>") '(group.next))
  (bind-hypr (kb "Z-S-,") '(group.move-window ((forward? . #f))))
  (bind-hypr (kb "Z-S-.") '(group.move-window ((forward? . #t))))
  (bind-hypr (kb "Z-S-<page_up>") '(group.move-window ((forward? . #f))))
  (bind-hypr (kb "Z-S-<page_down>") '(group.move-window ((forward? . #t)))))


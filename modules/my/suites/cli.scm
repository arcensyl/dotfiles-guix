(define-module (my suites cli)
  #:use-module (gnu)
  #:use-module (my core)
  #:use-module (my utils units)
  #:use-module (my system shells))

(define-unit* ((suites cli common) #:key disable-shell-integration?)
  (use-home-packages
   ;; System Information
   "lshw"
   "btop"
   "du-dust"

   ;; Networking
   "curl"
   "wget"

   ;; Data Manipulation
   "jq"
   "yq"

   ;; Misc.
   "tealdeer"
   "fzf")

  (unless disable-shell-integration?
    (run-on-shell-start "eval \"$(fzf --bash)\""
                        #:where 'bash)))

(define-unit* ((suites cli modern) #:key enable-aliases?)
  (use-home-packages
   "zoxide"
   "eza"
   "fd"
   "ripgrep"
   "bat")

  (run-on-shell-start "eval \"$(zoxide init bash)\""
                      #:where 'bash)

  (when enable-aliases?
    (provide-shell-alias "cd" "z")
    
    (provide-shell-alias "ls" "eza --oneline --icons=always")
    (provide-shell-alias "ll" "eza --oneline --icons=always --long")

    (provide-shell-alias "cat" "bat")))

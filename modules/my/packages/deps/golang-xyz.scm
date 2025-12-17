(define-module (my packages deps golang-xyz)
  #:use-module (guix packages)
  #:use-module (guix licenses)
  #:use-module (guix git-download)
  #:use-module (guix build-system go))

(define-public go-github-com-danibezoff-perspective-transform
  (package
   (name "go-github-com-danibezoff-perspective-transform")
   (version "git-6a756ba")
   
   (source (origin
            (method git-fetch)
            (uri (git-reference
                  (url "https://github.com/danibezoff/perspective-transform")
                  (commit "6a756ba8e1bac0ae09426a1d085ff8eae4a0e5f1")))
            (file-name (git-file-name name version))
            (sha256
             (base32 "0lj78rzb9bip62wnlygbrwwiwl1f0jh4058gnsyd6brz0h5wcsp7"))))

   (build-system go-build-system)

   (arguments
    (list #:import-path "github.com/danibezoff/perspective-transform/perspective"
          #:unpack-path "github.com/danibezoff/perspective-transform"))

   (home-page "https://github.com/danibezoff/perspective-transform")
   (synopsis "Create and apply perspective transforms")
   (description "Create and apply perspective transforms")
   (license expat)))

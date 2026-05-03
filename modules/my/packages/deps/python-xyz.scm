(define-module (my packages deps python-xyz)
  #:use-module (gnu packages)
  #:use-module (gnu packages machine-learning)
  #:use-module (gnu packages time)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages xorg)
  #:use-module (gnu packages python-xyz)
  #:use-module (gnu packages python-build)
  #:use-module (gnu packages python-web)
  #:use-module (guix packages)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix gexp)
  #:use-module (guix utils)
  #:use-module (guix git-download)
  #:use-module (guix build-system python)
  #:use-module (guix build-system pyproject))

;; A variant of ONNX without static registration.
;; This seems to be required to use the ONNX runtime.
(define-public onnx-non-static
  (package
   (inherit onnx)
   
   (arguments
    (substitute-keyword-arguments (package-arguments onnx)
                                  ((#:phases phases)
                                   #~(modify-phases #$phases
                                                    ;; Default tests don't work with my modified package.
                                                    (delete 'check)
                                                    
                                                    (add-after 'pass-cmake-arguments 'disable-static-registration
                                                               (lambda _
                                                                 (setenv "CMAKE_ARGS"
                                                                         (string-append (getenv "CMAKE_ARGS")
                                                                                        " -DONNX_DISABLE_STATIC_REGISTRATION=ON"))))))))))

;; A variant of the ONNX runtime which uses my non-static ONNX package.
(define-public onnxruntime-non-static
  (package
   (inherit onnxruntime)
   
   (inputs
    (modify-inputs (package-inputs onnxruntime)
                   (replace "onnx" onnx-non-static)))))

(define-public python-mss
  (package
   (name "python-mss")
   (version "10.1.0")
   
   (source (origin
            (method git-fetch)
            (uri (git-reference
                  (url "https://github.com/BoboTiG/python-mss")
                  (commit (string-append "v" version))))
            (file-name (git-file-name name version))
            (sha256
             (base32 "0dfh1nxlpbdj1ymz27905a9f2rlycadh8x5ggl91k0agv70w4mc0"))))

   
   (build-system pyproject-build-system)

   (native-inputs (list python-hatchling))
   
   (arguments
    (list #:tests? #f))
   
   (home-page "https://github.com/BoboTiG/python-mss")
   (synopsis "Cross-platform multiple screenshots module in pure Python")
   (description "An ultra fast cross-platform multiple screenshots module in pure Python using ctypes.")
   (license license:bsd-3)))

(define-public python-grpclib
  (package
   (name "python-grpclib")
   (version "0.4.9")
   
   (source (origin
            (method git-fetch)
            (uri (git-reference
                  (url "https://github.com/vmagamedov/grpclib")
                  (commit (string-append "v" version))))
            (file-name (git-file-name name version))
            (sha256
             (base32 "1m6n0hz14ik4l7ks5jzwv1x6ac3s15v02x8mia51zq1wplh44jgl"))))

   (build-system pyproject-build-system)

   (arguments
    (list #:phases
          #~(modify-phases %standard-phases
                           (delete 'check)
                           (delete 'sanity-check))))

   
   (native-inputs
    (list python-setuptools
          python-wheel))
   
   (home-page "https://github.com/vmagamedov/grpclib")
   (synopsis "Pure-Python gRPC implementation for asyncio")
   (description "Pure-Python gRPC implementation for asyncio.")
   (license license:bsd-3)))

(define-public python-betterproto
  (package
   (name "python-betterproto")
   (version "2.0.0b7")
   
   (source (origin
            (method git-fetch)
            (uri (git-reference
                  (url "https://github.com/danielgtaylor/python-betterproto")
                  (commit (string-append "v." version))))
            (file-name (git-file-name name version))
            (sha256
             (base32 "1cnn73isaj4z4y4k0nj7bkybdkihv76mv8ckqihss58cgwy15d2g"))))

   
   (build-system pyproject-build-system)

   ;; This library has many more dependencies when running tests.
   ;; To simplify the packaging process, I am just going to skip testing for now.
   
   (arguments
    (list #:tests? #f))
   
   (native-inputs
    (list python-poetry-core))
   
   (propagated-inputs
    (list python-grpclib
          python-dateutil
          python-typing-extensions
          python-jinja2))

   (home-page "https://github.com/danielgtaylor/python-betterproto")
   (synopsis "Python code generator and library for Protobuf 3 and async gRPC")
   (description "A clean, modern, Python 3.6+ code generator and library for Protobuf 3 and async gRPC.")
   (license license:expat)))

;; TEMP: Replace this with the upstream package.
;; For some reason, the python-pynput package is inaccessible on my system.
;; This is a copy of it from the actual package repository.

;; Source: https://codeberg.org/guix/guix/src/commit/c8985dd911c4c8e2948c888df8b54c9bc317625e/gnu/packages/python-xyz.scm#L26898

(define-public python-local-pynput
  (package
   (name "python-pynput")
   (version "1.8.1")
   (source
    (origin
     (method git-fetch)
     (uri (git-reference
           (url "https://github.com/moses-palmer/pynput")
           (commit (string-append "v" version))))
     (file-name (git-file-name name version))
     (sha256
      (base32 "00lnram5rm0amp5c1cjsw476bzi59g9m3l76ra29mp4jnz519sdc"))))
   (build-system pyproject-build-system)
   (arguments
    (list
     #:test-backend #~'unittest
     #:phases
     #~(modify-phases %standard-phases
                      (add-after 'unpack 'relax-requirements
                                 (lambda _
                                   (substitute* "setup.py"
                                                (("RUNTIME_PACKAGES \\+ SETUP_PACKAGES")
                                                 "RUNTIME_PACKAGES"))))
                      (delete 'check)
                      (add-before 'sanity-check 'start-xserver
                                  (lambda* (#:key inputs #:allow-other-keys)
                                    (let ((Xvfb (search-input-file inputs "/bin/Xvfb")))
                                      (system (format #f "~a :1 -screen 0 640x480x24 &"
                                                      Xvfb))
                                      (setenv "DISPLAY" ":1")))))))
   (propagated-inputs
    (list python-evdev python-xlib))
   (native-inputs
    (list python-setuptools xorg-server-for-tests))
   (home-page "https://github.com/moses-palmer/pynput")
   (synopsis "Send virtual input commands")
   (description
    "This package provides tools to monitor and control user input devices in Python.")
   (license license:lgpl3)))

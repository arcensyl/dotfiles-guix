(use-modules (gnu)
             (gnu home)
             (arc core)
             (arc util features)
             (arc system audio)
             (arc system nix)
             (arc system flatpak)
             (arc suites cli))

(set! system-type 'desktop)
(set! system-timezone "UTC")

(set! master-name "admin")
(set! master-comment "Administrator")
(set! master-home-directory "/home/admin")

(feat-require 'core)
(feat-require 'nix)
(feat-require 'flatpak)
  
(feat-require 'pipewire)

(feat-require 'cli-common)
(feat-require 'cli-modern)

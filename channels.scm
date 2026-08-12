;;; Copyright © 2025-2026 Arcensyl <dev@arcensyl.me>
;;;
;;; This file is NOT part of GNU Guix.
;;;
;;; This program is free software; you can redistribute it and/or modify it
;;; under the terms of the GNU General Public License as published by the Free
;;; Software Foundation; either version 3 of the License, or (at your option)
;;; any later version.
;;;
;;; This program is distributed in the hope that it will be useful, but
;;; WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
;;; or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
;;; for more details.
;;;
;;; You should have received a copy of the GNU General Public License along
;;; with this program.  If not, see <http://www.gnu.org/licenses/>.

(list (channel
       (name 'sijo)
       (url "https://git.sr.ht/~simendsjo/dotfiles")
       (branch "main")
       (introduction
        (make-channel-introduction
         "c352f7331b1722b2ffb964572c7f7fbec585bd2f"
         (openpgp-fingerprint
          "B0F2 D6C5 2936 95FD 57B5  D255 77BC 6345 B65D 6CFB"))))
      (channel
       (name 'guix-gaming-games)

       ;; TODO: Switch back to the upstream version of this channel.
       ;; This channel currently depends on the another channel, 'guix-past'.
       ;; As 'guix-past' is currently broken, this channel is broken too.

       ;; I'm now using a new fork which removes the broken dependency.
       ;; As of writing, this fix has not been merged back into upstream yet.
       
       (url "https://gitlab.com/gabor-udvari/games.git")
       (branch "openssl-1.0"))
      (channel
       (name 'nonguix)
       (url "https://gitlab.com/nonguix/nonguix")
       (branch "master")
       (introduction
        (make-channel-introduction
         "897c1a470da759236cc11798f4e0a5f7d4d59fbc"
         (openpgp-fingerprint
          "2A39 3FFF 68F4 EF7A 3D29  12AF 6F51 20A0 22FB B2D5"))))
      (channel
       (name 'guix)
       (url "https://git.savannah.gnu.org/git/guix.git")
       (branch "master")
       (introduction
        (make-channel-introduction
         "9edb3f66fd807b096b48283debdcddccfea34bad"
         (openpgp-fingerprint
          "BBB0 2DDF 2CEA F6A8 0D1D  E643 A2A0 6DF2 A33A 54FA")))))

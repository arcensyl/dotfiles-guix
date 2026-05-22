# Copyright © 2025-2026 Arcensyl <dev@arcensyl.me>
#
# This file is NOT part of GNU Guix.
#
# This program is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by the Free
# Software Foundation; either version 3 of the License, or (at your option)
# any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program.  If not, see <http://www.gnu.org/licenses/>.

alias rb := rebuild
alias up := update

# Simply list all the available recipes.
@_default:
    just --list

# Initialize the system called HOST with the specified partitions.
[confirm("Are you sure you want to initialize a system with these parameters?\n(y/n):")]
@init host boot root swap:
    @# Initializing file systems...
    sudo mkfs.fat -F32 -n 'guix-boot' '{{boot}}'
    sudo mkfs.ext4 -L 'guix-root' '{{root}}'
    sudo mkswap -L 'guix-swap' '{{swap}}'
    
    @# Mounting target system...
    sudo mount '{{root}}' /mnt
    sudo mkdir -p /mnt/boot/efi
    sudo mount '{{boot}}' /mnt/boot/efi
    
    @# Building system...
    GUIX_HOSTNAME='{{host}}' sudo -E guix system init main.scm /mnt
    
    @# Unmounting system...
    sudo umount /mnt/boot/efi
    sudo umount /mnt
    
    @# System initialized!

# Finish initializing a new system.
@post-init:
    @# Creating directories expected by this configuration...
    mkdir -p ~/.dotfiles/guix/gen
    mkdir -p ~/.dotfiles/live
    mkdir -p ~/.config/guix
    sudo mkdir -p "/nix/var/nix/profiles/per-user/$USER"
    sudo -E chown "$USER" "/nix/var/nix/profiles/per-user/$USER"
    
    @# Deploying unmanaged symlinks...
    ln -sf ~/.dotfiles/guix/channels.scm ~/.config/guix/channels.scm
    ln -sf ~/.dotfiles/live/* ~/.config/
    
    @# Building Nix profile...
    nix run 'path:gen/nix#profile.switch'
    
    # TODO: Consider setting up fonts for Flatpak here.
    
    @# System post-initialization has been finished.
    
# Rebuild this system to apply any configuration changes.
@rebuild:
    @# Rebuilding system...
    sudo -E guix system reconfigure main.scm
    
    @# Rebuilding Nix profile...
    sleep 1 # Wait for Guix Home activation.
    nix run 'path:gen/nix#profile.switch'
    #nix run 'path:gen/nix#profile.pin'
    
    @# System rebuilt.

# Update this system by fetching any new package versions and doing a rebuild.
@update:
    @# Updating Guix channels...
    guix pull
    
    @# Updating Nix flake inputs...
    # Because Nix package pinning can't be reverted, we save the old lock file.
    cp -f gen/nix/flake.lock gen/nix/flake.lock.old
    nix flake update --flake 'path:gen/nix'
    
    @# Pull complete. Rebuilding system...
    sleep 1 # Wait for Guix Home activation.
    sudo -E guix system reconfigure main.scm
    
    @# Rebuilding Nix profile...
    nix run 'path:gen/nix#profile.switch'
    
    # Package pinning doesn't currently work because the '/etc/nix' directory is read-only.
    #sudo nix run 'path:gen/nix#profile.pin'
    
    @# System updated. You should consider rebooting soon.

# Test this configuration by doing a dry run of a system build.
@test:
    @# Simulating system build...
    guix system reconfigure --dry-run main.scm
    @# This system can be built without errors.

# Build an installer image and flash TARGET with it.
[confirm("Are you sure you want to flash that target device with an installer image?\n(y/n):")]
@flash target:
    @# Building installer image...
    make-guix-installer gen/installer.iso
    
    @# Flashing target device...
    sudo dd if=gen/installer.iso of='{{target}}' status=progress
    
    @# Target device flashed and ready for use.

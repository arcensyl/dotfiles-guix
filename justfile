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

# TODO: Completely revamp installation process.

# Prepare for and do an initial build of the system named HOST.
[confirm("Are you sure you want to initialize this system with this configuration? (y/n):")]
@init host:
    @# Creating directories expected by this configuration...
    mkdir -p ~/.dotfiles/guix/gen/auth
    mkdir -p ~/.dotfiles/live
    mkdir -p ~/.util
    mkdir -p ~/.config/guix
    sudo mkdir -p "/nix/var/nix/profiles/per-user/$USER"
    sudo chown "$USER" "/nix/var/nix/profiles/per-user/$USER"
    
    @# Pulling down required resources from the internet... 
    curl -o gen/auth/nonguix.pub 'https://substitutes.nonguix.org/signing-key.pub'
    
    @# Deploying unmanaged symlinks...
    ln -sf ~/.dotfiles/guix/channels.scm ~/.config/guix/channels.scm
    ln -sf ~/.dotfiles/live/* ~/.config/
    
    # HACK: We need to symlink fonts installed by Guix Home so Flatpaks can find them.
    # Flatpaks should also be given read-only access to '/gnu/store'.
    # Yes, I know this is pretty ugly...
    mkdir -p ~/.local/share/fonts
    ln -sf ~/.guix-home/profile/share/fonts ~/.local/share/fonts/guix
    ln -s /home/arc/.guix-home/profile/share/fonts/truetype .fonts
    
    @# Generating host-specific configuration...
    mkdir -p ./hosts/'{{host}}'
    # TODO: Copy 'config.scm' from default host.
    ./scripts/generate-hardware-scm '{{host}}'
    
    @# Building system...
    GUIX_HOSTNAME='{{host}}' sudo -E guix system reconfigure main.scm
    
    @# Building Nix profile...
    sleep 1 # Wait for Guix Home activation.
    nix run 'path:gen/nix#profile.switch'
    nix run 'path:gen/nix#profile.pin'
    
    @# System initialized! Please reboot at your earliest convenience.

# Rebuild this system to apply any configuration changes.
@rebuild:
    @# Rebuilding system...
    sudo -E guix system reconfigure main.scm
    
    @# Rebuilding Nix profile...
    sleep 1 # Wait for Guix Home activation.
    nix run 'path:gen/nix#profile.switch'
    nix run 'path:gen/nix#profile.pin'
    
    @# System rebuilt.

# Update this system by fetching any new package versions and doing a rebuild.
@update:
    @# Updating Guix channels...
    guix pull
    
    @# Updating Nix flake inputs...
    # Because Nix package pinning can't be reverted, we save the old lock file.
    cp -f gen/nix/flake.lock gen/nix/flake.lock.old
    nix flake update --flake gen/nix
    
    @# Pull complete. Rebuilding system...
    sleep 1 # Wait for Guix Home activation.
    sudo -E guix system reconfigure main.scm
    
    @# Rebuilding Nix profile...
    nix run 'path:gen/nix#profile.switch'
    sudo nix run 'path:gen/nix#profile.pin'
    
    @# System updated. You should consider rebooting soon.

# Test this configuration by doing a dry run of a system build.
@test:
    @# Simulating system build...
    guix system reconfigure --dry-run main.scm
    @# This system can be built without errors.

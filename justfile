# Simply list all the available recipes.
@_default:
    just --list

# Prepare for and do an initial build of the system named HOST.
@init host:
    @# Creating directories expected by this configuration...
    mkdir -p ~/.dotfiles/guix/gen
    mkdir -p ~/.dotfiles/live
    mkdir -p ~/.util
    mkdir -p ~/.config/guix
    
    @# Deploying unmanaged symlinks...
    ln -sf ~/.dotfiles/guix/channels.scm ~/.config/guix/channels.scm
    ln -sf ~/.dotfiles/live/* ~/.config/
    
    @# Generating host-specific configuration...
    mkdir -p ./hosts/'{{host}}'
    # TODO: Copy 'config.scm' from default host.
    ./scripts/generate-hardware-scm '{{host}}'
    
    @# Running initial system build...
    GUIX_HOSTNAME='{{host}}' sudo -E guix system reconfigure main.scm
    @# System initialized! Please reboot at your earliest convenience.

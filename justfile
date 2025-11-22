alias rb := rebuild
alias up := update

# Simply list all the available recipes.
@_default:
    just --list

# Prepare for and do an initial build of the system named HOST.
[confirm("Are you sure you want to initialize this system with this configuration? (y/n):")]
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
    
    @# Building system for the first time...
    GUIX_HOSTNAME='{{host}}' sudo -E guix system reconfigure main.scm
    @# System initialized! Please reboot at your earliest convenience.

# Rebuild this system to apply any configuration changes.
@rebuild:
    @# Rebuilding system...
    GUIX_HOSTNAME="$(hostname)" sudo -E guix system reconfigure main.scm
    @# System rebuilt.

# Update this system by fetching any new package versions and doing a rebuild.
@update:
    @# Fetching the latest version of all packages...
    guix pull
    
    @# Pull complete. Rebuilding system...
    GUIX_HOSTNAME="$(hostname)" sudo -E guix system reconfigure main.scm
    @# System updated. You should consider rebooting soon.

# Test this configuration by doing a dry run of a system build.
@test:
    @# Simulating system build...
    GUIX_HOSTNAME="$(hostname)" guix system reconfigure --dry-run main.scm
    @# This system can be built without errors.

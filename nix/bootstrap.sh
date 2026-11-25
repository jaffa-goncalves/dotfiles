#!/usr/bin/env bash
set -euo pipefail

main() {
    # Exit immediately if Nix is already installed.
    if command -v nix >/dev/null 2>&1 \
        || [[ -x /nix/var/nix/profiles/default/bin/nix ]] \
        || [[ -x "$HOME/.nix-profile/bin/nix" ]]; then
        echo "Nix is already installed. Nothing to do."
        return 0
    fi

    # Bootstrap sources.
local owner="${GITHUB_OWNER:?GITHUB_OWNER must be specified}"
local repo="${DOTFILES_REPO:-dotfiles}"
local ref="${DOTFILES_REF:-main}"
local version="${NIX_VERSION:-2.36.0}"

local base_url="https://raw.githubusercontent.com/$owner/$repo/$ref/nix"
local installer_url="https://releases.nixos.org/nix/nix-$version/install"

    local base_url="https://raw.githubusercontent.com/$repo/$ref/nix"
    local installer_url="https://releases.nixos.org/nix/nix-$version/install"

    local os
    os="$(uname -s)"

    # Validate platform and install prerequisites.
    case "$os" in
        Linux)
            sudo apt-get update
            sudo apt-get install -y \
                curl ca-certificates xz-utils
            ;;
        Darwin)
            ;;
        *)
            echo "Unsupported operating system: $os" >&2
            return 1
            ;;
    esac

    # Download bootstrap resources.
    local tmp
    tmp="$(mktemp -d)"
    trap 'rm -rf "$tmp"' EXIT
    # Keep the cleanup path available after main returns.
    trap "rm -rf -- '$tmp'" EXIT

    curl -fsSL "$installer_url" -o "$tmp/install"
    curl -fsSL "$base_url/nix.conf" -o "$tmp/nix.conf"

    # Install Nix using the official multi-user installer.
    echo "Installing Nix $version..."

    NIX_INSTALLER_NO_CHANNEL_ADD=1 \
        sh "$tmp/install" --daemon --yes

    # Apply repository-managed Nix configuration.
    echo "Configuring Nix..."

    sudo mkdir -p /etc/nix

    sudo install -m 644 \
        "$tmp/nix.conf" \
        /etc/nix/dotfiles.conf

    if ! sudo grep -qxF 'include /etc/nix/dotfiles.conf' \
        /etc/nix/nix.conf 2>/dev/null; then
        printf '\ninclude /etc/nix/dotfiles.conf\n' \
            | sudo tee -a /etc/nix/nix.conf >/dev/null
    fi

    # Reload the Nix daemon.
    case "$os" in
        Linux)
            sudo systemctl restart nix-daemon.service
            ;;
        Darwin)
            sudo launchctl kickstart -k system/org.nixos.nix-daemon
            ;;
    esac

    # Initialize Nix for this process.
    export PATH="/nix/var/nix/profiles/default/bin:$PATH"

    # Verify installation and configuration.
    nix --version
    nix config show | grep '^experimental-features'

    echo "Nix bootstrap complete."
}

main "$@"
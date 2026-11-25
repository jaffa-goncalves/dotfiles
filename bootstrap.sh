#!/usr/bin/env bash
set -euo pipefail

OS="$(uname -s | tr '[:upper:]' '[:lower:]')"
ARCH="$(uname -m | tr '[:upper:]' '[:lower:]')"

echo "OS   :  $OS"
echo "ARCH :  $ARCH"

case "$OS" in
  darwin)
    PLATFORM="macos"
    ;;
  linux)
    PLATFORM="linux"
    ;;
  *)
    echo "Unsupported OS : $OS"
    exit 1
    ;;
esac

case "$ARCH" in
  x86_64|amd_64)
    ARCH="x86_64"
    ;;
  arm64|aarch64)
    ARCH="arm64"
    ;;
  *)
    echo "Unsupported architecture: $ARCH"
    exit 1
    ;;
esac   

TARGET="${PLATFORM}-${ARCH}"

echo "$TARGET"


micromamba_platform() {
  case "$PLATFORM" in
    macos) echo "osx" ;;
    linux) echo "linux" ;;
  esac
}

micromamba_arch() {
  case "$ARCH" in
    arm64) echo "arm64";;
    x86_64) echo "64";;
  esac
}

github_release_platform() {
  case "$PLATFORM" in
    macos) echo "apple-darwin" ;;
    linux) echo "unkown-linux-gnu";;
  esac
}

starship_platform() {
  case "$PLATFORM" in
    macos) echo "Darwin" ;;
    linux) echo "Linux"  ;;
  esac
}

fzf_release_platform() {
  case "$PLATFORM" in
    macos) echo "darwin" ;;
    linux) echo "linux";;
  esac
}

fzf_release_arch() {
  case "$ARCH" in
    arm64) echo "arm64";;
    x86_64) echo "amd64";;
  esac
}

github_release_arch() {
  case "$ARCH" in
    arm64) echo "aarch64" ;;
    x86_64) echo "x86_64" ;;
  esac
}


install_micromamba() {
  local mm="$HOME/micromamba/bin/micromamba"
  [ -x "$mm" ] && { echo "micromamba already installed"; return; }

 local mm_os mm_arch
 mm_os="$(micromamba_platform)"
 mm_arch="$(micromamba_arch)"

 local url="https://micro.mamba.pm/api/micromamba/${mm_os}-${mm_arch}/latest"

 echo "Installing micromamba for ${mm_os}-${mm_arch}"

 mkdir -p "$HOME/micromamba/bin"
 tmp="$(mktemp -d)"

 curl -L "$url" | tar -xvj -C "$tmp"
 mv "$tmp/bin/micromamba" "$mm"
 rm -rf "$tmp"
}

init_micromamba() {
  local mm="$HOME/micromamba/bin/micromamba"

  if [ ! -x "$mm" ]; then
    echo "micromamba not installed skipping init"
    return
  fi

  echo "Configuring micromamba defaults"

  "$mm" config set auto_activate_base false
}

install_starship() {
  local platform="$1"
  if command -v starship >/dev/null 2>&1; then
    echo "Starship already installed"
    return
  fi

  echo "Installing Starship"
  case "$platform" in
    Darwin)
      brew install starship
      ;;
    Linux)
      echo "No Installer"
      ;;
    *)
      echo "No Installer"
      ;;
  esac
  echo "Starship Installed"
}

install_zsh_autosuggest() {
  local platform="$1"
  case "$platform" in
    Darwin)
        if brew list zsh-autosuggestions >/dev/null 2>&1; then
    echo "zsh-autosuggestions already installed"
  else
    echo "Insalling zsh autosuggestions"
    brew install zsh-autosuggestions
  fi
      ;;
    Linux)
      echo "No Installer"
      ;;
    *)
      echo "No Installer"
      ;;
  esac
}

install_zsh_syntax() {
  local platform="$1"
  case "$platform" in
    Darwin)
        if brew list zsh-syntax-highlighting >/dev/null 2>&1; then
    echo "zsh-syntax-highlighting already installed"
  else
    echo "Insalling zsh syntax highlighting"
    brew install zsh-syntax-highlighting
  fi
      ;;
    Linux)
      echo "No Installer"
      ;;
    *)
      echo "No Installer"
      ;;
  esac
}

install_helix() {
  local platform="$1"
  case "$platform" in
    Darwin)
        if brew list helix >/dev/null 2>&1; then
    echo "helix already installed"
  else
    echo "Insalling helix"
    brew install helix
  fi
      ;;
    Linux)
      echo "No Installer"
      ;;
    *)
      echo "No Installer"
      ;;
  esac
}



ensure_package() {
  local platform="$1"
  local item="$2"
  case "$platform" in
    Darwin)
        if brew list "$item" >/dev/null 2>&1; then
    echo "$item already installed"
  else
    echo "Installing $item"
    brew install "$item"
  fi
      ;;
    Linux)
      echo "No Installer"
      ;;
    *)
      echo "No Installer"
      ;;
  esac
}


install_zoxide() {
  if command -v zoxide >/dev/null 2>&1; then
    echo "zoxide already installed"
    return
  fi

  echo "Installing zoxide"
  mkdir -p "$HOME/.local/bin"
  curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh \
  | sh -s -- --bin-dir "$HOME/.local/bin"
}

install_eza() {
  if command -v eza >/dev/null 2>&1; then
    echo "eza already installed"
    return
  fi

  echo "Installing eza..."
  mkdir -p "$HOME/.local/bin"

  local os arch
  os="$(uname -s | tr '[:upper:]' '[:lower:]' )"
  arch="$(uname -m | tr '[:upper:]' '[:lower:]' )"

  case "$arch" in
    arm64|aarch64) arch="arm64";;
    x86_64|amd64)  arch="x86_64";;
    *) echo "Unsupported arch: $arch"; return 1 ;;
  esac

  case "$os" in
    darwin)
      if command -v brew >/dev/null 2>&1; then
        echo "Installing eza via Homebrew..."
        brew install eza;
        return
      else
        echo "eza has no macOS binaries"
        echo "install Homebrew, then run : brew install eza"
        return 1
        fi
      ;;
    linux)  os="unknown-linux-gnu";;
    *) echo "Unsupported OS: $os"; return 1;;
  esac

  ext="tar.gz"

  url="https://github.com/eza-community/eza/releases/latest/download/eza_${arch}-${os}.${ext}"

echo "$url"
  
tmp="$(mktemp -d)"
archive="$tmp/archive"

curl -L "$url" -o "$tmp/archive"

tar -xzf "$archive" -C "$tmp"


mkdir -p "$HOME/.local/bin"

mv "$tmp/eza" "$HOME/.local/bin/eza"
chmod +x "$HOME/.local/bin/eza"
rm -rf "$tmp"

echo "eza installed succesfully"
}

install_fd() {
  if command -v fd >/dev/null 2>&1; then
    echo "fd already installed"
    return
  fi

  os="$(github_release_platform)"
  arch="$(github_release_arch)"

  version="v10.3.0"
  url="https://github.com/sharkdp/fd/releases/download/${version}/fd-${version}-${arch}-${os}.tar.gz"

  echo "$url"

  tmp="$(mktemp -d)"
  archive="$tmp/fd.tar.gz"

  mkdir -p "$HOME/.local/bin"

  curl -L "$url" -o "$archive"
  tar -xzf "$archive" -C "$tmp"

  if ! ls "$tmp"/fd*/fd >/dev/null 2>&1; then
    echo "fd binary not found after extraction"
    rm -rf "$tmp"
    return 1
  fi

  mv "$tmp"/fd*/fd "$HOME/.local/bin/fd"
  chmod +x "$HOME/.local/bin/fd"
  rm -rf "$tmp"

  echo "fd installed successfully"
}

install_rg() {
  if command -v rg >/dev/null 2>&1; then
    echo "rg is already installed"
    return
  fi

  os="$(github_release_platform)"
  arch="$(github_release_arch)"

  version="15.1.0"
  url="https://github.com/BurntSushi/ripgrep/releases/download/${version}/ripgrep-${version}-${arch}-${os}.tar.gz"

  echo "$url"

  tmp="$(mktemp -d)"

  archive="$tmp/rg.tar.gz"

  mkdir -p "$HOME/.local/bin"

  curl -L "$url" -o "$archive"
  tar -xzf "$archive" -C "$tmp"

  if ! ls "$tmp"/ripgrep*/rg >/dev/null 2>&1; then
    echo "rg binary not found after extraction"
    rm -rf "$tmp"
    return 1
  fi

  mv "$tmp"/ripgrep*/rg "$HOME/.local/bin/rg"
  chmod +x "$HOME/.local/bin/rg"
  rm -rf "$tmp"

  echo "rg installed successfully"

}

install_fzf() {
  if command -v fzf >/dev/null 2>&1; then
    echo "fzf already installed"
    return
  fi

  os="$(fzf_release_platform)"
  arch="$(fzf_release_arch)"

  version="0.67.0"
  url="https://github.com/junegunn/fzf/releases/download/v${version}/fzf-${version}-${os}_${arch}.tar.gz"

  echo "$url"

  tmp="$(mktemp -d)"
  archive="$tmp/fzf.tar.gz"

  mkdir -p "$HOME/.local/bin"

  curl -L "$url" -o "$archive"
  tar -xzf "$archive" -C "$tmp"

  if [ ! -x "$tmp/fzf" ]; then
    echo "fzf binary not found after extraction"
    rm -rf "$tmp"
    return 1
  fi

  mv "$tmp/fzf" "$HOME/.local/bin/fzf"
  chmod +x "$HOME/.local/bin/fzf"
  rm -rf "$tmp"

  echo "fzf installed successfully"
}

main() {
  ensure_package "$(uname -s)" gh
  ensure_package "$(uname -s)" uv
  ensure_package "$(uname -s)" micromamba
  ensure_package "$(uname -s)" llvm
  ensure_package "$(uname -s)" rustup-init
  rustup-init -y
  ensure_package "$(uname -s)" fnm
  ensure_package "$(uname -s)" tmux
  ensure_package "$(uname -s)" eza
  ensure_package "$(uname -s)" fd
  ensure_package "$(uname -s)" fzf
  ensure_package "$(uname -s)" rg
  ensure_package "$(uname -s)" zoxide 
  ensure_package "$(uname -s)" starship
  ensure_package "$(uname -s)" zsh-autosuggestions
  ensure_package "$(uname -s)" zsh-syntax-highlighting
  ensure_package "$(uname -s)" helix
  ensure_package "$(uname -s)" font-jetbrains-mono-nerd-font
  ensure_package "$(uname -s)" ollama
}

main




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

fd_platform() {
  case "$PLATFORM" in
    macos) echo "apple-darwin" ;;
    linux) echo "unkown-linux-gnu";;
  esac
}

fd_arch() {
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
  if command -v starship >/dev/null 2>&1; then
    echo "Starship already installed"
    return
  fi

  echo "Installing Starsthip"
  curl -sS https://starship.rs/install.sh | sh -s -- -y
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

  os="$(fd_platform)"
  arch="$(fd_arch)"

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

main() {
  install_zoxide
  install_eza
  install_fd
  install_micromamba
  init_micromamba
  install_starship
}

main




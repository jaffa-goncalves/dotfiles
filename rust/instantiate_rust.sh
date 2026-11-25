init_rustup() {
  
  if ! command -v rustup >/dev/null 2>&1; then
    echo "rustup not installed"
    return 1
  fi
  if [ ! d "$HOME/.cargo" ]; then
    echo "Initializing Rust"
    rustup-init -y
  else
    echo "Rust Already Installed"
  fi
}
instantiate_components() {
  rust component add rustfmt clippy >/dev/null 2>&1;
  echo "Base Components Installed"
}

init_rustup
instantiate_components

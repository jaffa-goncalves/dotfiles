
# zoxide (safe init)
if command -v zoxide >/dev/null 2>&1; then
  source $HOME/dotfiles/shell/loaders/tools/zoxide.sh
fi

# starship
if command -v starship >/dev/null 2>&1; then
  source "$HOME/dotfiles/shell/loaders/tools/starship.sh"
fi

# eza
if command -v eza >/dev/null 2>&1; then
  source "$HOME/dotfiles/shell/loaders/tools/eza.sh"
fi

# Micromamba
echo "MAMBA_EXE=$MAMBA_EXE"
if [ -z "$DISABLE_MAMBA" ]; then
  echo "DISABLE_MAMBA is unset (mamba enabled)"
else
  echo "DISABLE_MAMBA is set to '$DISABLE_MAMBA' (mamba disabled)"
fi

if [ -x "$MAMBA_EXE" ]; then
    echo "MAMBA path exists"
else
    echo "MAMBA path doesn't exist"
fi

if [ -z "$DISABLE_MAMBA" ] && [ -x "$MAMBA_EXE" ]; then
  source "$HOME/dotfiles/shell/loaders/tools/micromamba.sh"
  echo "Enabled Micromamba"
fi

# Rust / Cargo
if [ -d "$HOME/.cargo/bin" ]; then
  export PATH="$HOME/.cargo/bin:$PATH"
fi

#fnm
source "$HOME/dotfiles/shell/loaders/tools/fnm.sh"

# Auto-suggestions and completions
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

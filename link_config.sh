link_config() {
  local name="$1"
  local target="$HOME/.config/$name"
  local source="$HOME/dotfiles/$name"

  mkdir -p "$HOME/.config"

  if [ ! -d "$source" ]; then
    echo "Missing config : $name"
    return 1
  fi

  if [ -e "$target" ] && [ ! -L "$target" ]; then
    echo "Backing up existing config"
    mv "$target" "$target.bak"
  fi

  if [ -L "$target" ]; then
    echo "$name is already linked"
    return 0
  fi

  echo "Linking $name Config"
  ln -sfn "$source" "$target" || return 1
  echo "Linked $name Config"
  return 0
}

link_config helix
link_config starship
link_config tmux
link_config wezterm
link_config shell
link_config aerospace

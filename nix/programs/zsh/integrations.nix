{ lib, ... }:

{
  programs.zsh.initContent = lib.mkMerge [
    (lib.mkOrder 550 ''
      # Homebrew
      if [[ -x /opt/homebrew/bin/brew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
      fi

      # Legacy shell functions
      for file in "$HOME"/dotfiles/shell/functions/*.sh(N); do
        source "$file"
      done

      # Node.js version manager
      if command -v fnm >/dev/null 2>&1; then
        eval "$(fnm env --use-on-cd --shell zsh)"
      fi
    '')

    (lib.mkOrder 1500 ''
      # Automatically attach to tmux
      if [[ -o interactive ]] &&
         [[ -z "''${TMUX:-}" ]] &&
         command -v tmux >/dev/null 2>&1; then

        if tmux has-session -t main 2>/dev/null; then
          exec tmux attach -t main
        else
          exec tmux new-session -s main
        fi
      fi
    '')
  ];
}
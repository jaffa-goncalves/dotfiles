{ ... }:

{
  programs.zsh.shellAliases = {
    config = "code ~/dotfiles";
    reload = "exec zsh";
    rs = "exec zsh";
    rebuild = "sudo darwin-rebuild switch --flake ~/dotfiles/nix#macbook && exec zsh -l";
    rollback = "sudo darwin-rebuild --rollback";
  };
}
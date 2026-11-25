{ ... }:

{
  imports = [
    ./aliases.nix
    ./functions.nix
    ./integrations.nix
  ];

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    defaultKeymap = "emacs";

    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    history = {
      path = "$HOME/.zsh_history";
      size = 5000;
      save = 5000;
      share = true;
      ignoreDups = true;
      ignoreSpace = true;
    };
  };
}
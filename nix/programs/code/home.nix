{ pkgs, ... }:

{
  imports = [
    ./extensions.nix
    ./settings.nix
  ];

  home.packages = [
    pkgs.nerd-fonts.jetbrains-mono
  ];

  programs.vscode = {
    enable = true;
    package = pkgs.vscode;
  };
}
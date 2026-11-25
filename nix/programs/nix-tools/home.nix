{ pkgs, ... }:

{
  home.packages = with pkgs; [
    nixfmt
    statix
    deadnix
    nixd
    nix-tree
    nix-output-monitor
  ];
}
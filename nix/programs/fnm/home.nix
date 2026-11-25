{ pkgs, lib, ... }:

{
  home.packages = [
    pkgs.fnm
  ];

  programs.zsh.initContent = lib.mkOrder 550 ''
    eval "$(${pkgs.fnm}/bin/fnm env --use-on-cd --shell zsh)"
  '';
}
{ lib, ... }:

{
  programs.zsh.initContent = lib.mkOrder 1200 ''
    move() {
      mv -iv -- "$@" .
    }

    bring() {
      cp -iv -- "$@" .
    }

    enter() {
      mkdir -p -- "$1" && cd -- "$1"
    }

    cd() {
      if [[ $# -eq 0 ]]; then
        z
      elif [[ "$1" == "-" ]]; then
        builtin cd -
      else
        z "$@"
      fi
    }
  '';
}
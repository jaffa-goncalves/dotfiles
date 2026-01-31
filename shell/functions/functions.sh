move () {
  mv -iv "$@" .
}

bring () {
  cp -iv "$@" .
}

enter () {
  mkdir -p -- "$1" && cd -- "$1"
}

ac() {
  $EDITOR  ~/dotfiles/shell/aliases.sh
}

zc() {
  $EDITOR  ~/dotfiles/shell/zshrc
}

sc() {
  $EDITOR ~/dotfiles/starship/starship.toml
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

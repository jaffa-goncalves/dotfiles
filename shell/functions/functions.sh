move () {
  mv -iv "$@" .
}

bring () {
  cp -iv "$@" .
}

enter () {
  mkdir -p -- "$1" && cd -- "$1"
}


eval "$(zoxide init zsh)"

# zoxide-powered cd override
cd() {
    if [[ $# -eq 0 ]]; then
      z
    elif [[ "$1" == "-" ]]; then
      builtin cd -
    else
      z "$@"
    fi
}
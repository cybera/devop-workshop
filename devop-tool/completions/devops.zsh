if [[ ! -o interactive ]]; then
    return
fi

compctl -K _devops devops

_devops() {
  local word words completions
  read -cA words
  word="${words[2]}"

  if [ "${#words}" -eq 2 ]; then
    completions="$(devops commands)"
  else
    completions="$(devops completions "${word}")"
  fi

  reply=("${(ps:\n:)completions}")
}

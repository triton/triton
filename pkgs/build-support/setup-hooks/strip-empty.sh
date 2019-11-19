fixupOutputHooks+=(_doStrip)

_doStrip() {
  [ -n "${doStrip-1}" ] || return 0
  header "Stripping in: $prefix"
  "$stripAction"
}

isELF() {
  [ "$(head -c 4 "$1")" = $'\x7f''ELF' ]
}

isAr() {
  [ "$(head -c 8 "$1")" = '!<arch>'$'\x0a' ]
}

stripEmpty() {
  local fail=0
  local file

  for file in $(find "$prefix" -name include -prune , -type f); do
    isELF "$file" || isAr "$file" || continue
    echo "File requires stripping: $file" >&2
    fail=1
  done
  (( fail == 0 ))
}

: ${stripAction=stripEmpty}

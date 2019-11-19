fixupOutputHooks+=(_doPatchELF)

_doPatchELF() {
  [ -n "${doPatchELF-1}" ] || return 0
  header "PatchELF in: $prefix"
  "$patchELFAction"
}

isDynamicELF() {
  isELF "$1" || return
  grep -q '.interp' "$file"
}

patchELFEmpty() {
  local fail=0
  local file

  for file in $(find "$prefix" -name include -prune , -type f); do
    isDynamicELF "$file" || continue
    echo "File requires patchelf: $file" >&2
    fail=1
  done
  (( fail == 0 ))
}

: ${patchELFAction=patchELFEmpty}

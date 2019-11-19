fixupOutputHooks+=(_doPatchShebangs)

_doPatchShebangs() {
  [ -n "${doPatchShebangs-1}" ] || return 0
  header "Patching shebangs in: $prefix"
  "$patchShebangsAction"
}

isScript() {
  [ "$(head -c 2 "$1")" = "#!" ]
}

getInterp() {
  head -n 1 "$1" | sed 's/^#![ ]*//'
}

shouldIgnore() {
  local -n var="$1"
  local val="$2"

  local regex
  for regex in "${var[@]}"; do
    [[ "$val" =~ ^$regex$ ]] && return 0
  done
  return 1
}

patchShebangsEmpty() {
  local fail=0
  local file

  local -a ignored=("${patchShebangsInterpIgnore[@]}" "$NIX_STORE.*" '/bin/sh( .*)?')

  for file in $(find "$prefix" -name include -prune , -type f -executable); do
    isScript "$file" || continue
    shouldIgnore patchShebangsFileIgnore "$file" && continue
    local interp
    interp="$(getInterp "$file")" || return
    shouldIgnore ignored "$interp" && continue
    echo "File requires shebang patching: $file" >&2
    fail=1
  done
  (( fail == 0 ))
}

: ${patchShebangsAction=patchShebangsEmpty}

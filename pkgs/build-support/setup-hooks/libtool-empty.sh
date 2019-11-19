fixupOutputHooks+=(_doFixLibtool)

_doFixLibtool() {
  [ -n "${doFixLibtool-1}" ] || return 0
  header "Fixing libtool in: $prefix"
  "$fixLibtoolAction"
}

fixLibtoolEmpty() {
  local fail=0
  local file

  for file in $(find "$prefix" -name include -prune , -name '*'.la -type f); do
    echo "File requires libtool fixing: $file" >&2
    fail=1
  done
  (( fail == 0 ))
}

: ${fixLibtoolAction=fixLibtoolEmpty}

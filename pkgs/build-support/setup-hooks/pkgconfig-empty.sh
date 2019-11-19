fixupOutputHooks+=(_doFixPkgconfig)

_doFixPkgconfig() {
  [ -n "${doFixPkgconfig-1}" ] || return 0
  header "Fixing pkgconfig in: $prefix"
  "$fixPkgconfigAction"
}

fixPkgconfigEmpty() {
  local fail=0
  local file

  for file in $(find "$prefix" -name include -prune , -name '*'.pc -type f); do
    echo "File requires pkgconfig fixing: $file" >&2
    fail=1
  done
  (( fail == 0 ))
}

: ${fixPkgconfigAction=fixPkgconfigEmpty}

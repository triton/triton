# This setup hook strips libraries and executables in the fixup phase.

fixupOutputHooks+=(_doStrip)

_doStrip() {
  if [ -n "${dontStrip-}" ]; then
    return 0
  fi

  local allFlags="${stripAllFlags--s}"
  local debugFlags="${stripDebugFlags--S}"
  header "Stripping in $prefix"

  if ! $READELF --version >/dev/null 2>&1; then
    echo "Missing readelf" >&2
    exit 1
  fi

  local file
  for file in $(find "$prefix" -type f); do
    if ! $READELF -h "$file" >/dev/null 2>&1; then
      continue
    fi
    if [[ "$file" =~ \.[ao]$ ]]; then
      echo "Stripping (debug only): $file" >&2
      $STRIP $debugFlags "$file"
    else
      echo "Stripping (all): $file" >&2
      $STRIP $allFlags "$file"
    fi
  done
  stopNest
}

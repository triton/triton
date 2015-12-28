# This setup hook creates absolute references to pkgconfig files in the fixup phase.

fixupOutputHooks+=(_doAbsolutePkgconfig)

_doAbsolutePkgconfig() {
  if [ -z "$dontAbsolutePkgconfig" ]; then
    header "Fixing up pkgconfig paths"
    addOutputPkgconfigPaths
    pkgconfigFiles | rewritePkgconfigFiles
    stopNest
  fi
}

rewritePkgconfigFiles() {
  local pkgfile
  while read pkgfile; do
    local absoluteDeps
    absoluteDeps="$(pkgconfigRequires "$pkgfile" | toAbsoluteDependencies)"
    local absoluteDepsPrivate
    absoluteDepsPrivate="$(pkgconfigRequiresPrivate "$pkgfile" | toAbsoluteDependencies)"

    sed -i "$pkgfile" \
      -e "s@^Requires:.*\$@Requires: $(echo $absoluteDeps)@g" \
      -e "s@^Requires.private:.*\$@Requires.private: $(echo $absoluteDepsPrivate)@g"
  done
}

toAbsoluteDependencies() {
  local dep
  while read dep; do
    local absoluteDep
    absoluteDep="$(pkgconfigPath $dep)"
    if [ "${absoluteDep:0:1}" != "/" ]; then
      echo "Found a non-absolute dependency $absoluteDep in $pkgfile" >&2
      return 1
    fi
    if [ "$absoluteDep" != "$dep" ] && [ "$(basename "$absoluteDep" | sed 's@^\(.*\)\.pc$@\1@g')" != "$dep" ]; then
      echo "Found a dependency that doesn't match: $absoluteDep != $dep" >&2
      return 1
    fi
    echo "$absoluteDep"
  done
}

addOutputPkgconfigPaths() {
  local output;
  for output in $outputs; do
    export PKG_CONFIG_PATH="$PKG_CONFIG_PATH${PKG_CONFIG_PATH:+:}${!output}/lib/pkgconfig"
  done
}

pkgconfigRequires() {
  local name;
  name="$1"
  if ! pkg-config --print-requires "$name" | awk '{print $1}'; then
    echo "Failed to enumerate all of the 'Requires:' dependencies $name" >&2
    return 1
  fi
}

pkgconfigRequiresPrivate() {
  local name;
  name="$1"
  if ! pkg-config --print-requires-private "$name" | awk '{print $1}'; then
    echo "Failed to enumerate all of the 'Requires.private:' dependencies $name" >&2
    return 1
  fi
}

pkgconfigFiles() {
  find "${prefix}/lib/pkgconfig" -name \*.pc 2>/dev/null || true
}

# Takes a pkg name and returns the path to the pkgconfig file
pkgconfigPath() {
  local name; local path;
  name="$1"
  if [ "${name:0:1}" = "/" ] && [ -e "$name" ]; then
    echo "$name"
    return 0
  fi
  for path in $(echo "$PKG_CONFIG_PATH" | tr ':' '\n'); do
    if [ -e "$path/$name.pc" ]; then
      echo "$path/$name.pc"
      return 0
    fi
  done
  echo "Missing pkg-config file for $name" >&2
  return 1
}

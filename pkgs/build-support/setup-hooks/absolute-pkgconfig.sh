# This setup hook creates absolute references to pkgconfig files in the fixup phase.

fixupOutputHooks+=(_doAbsolutePkgconfig)

_doAbsolutePkgconfig() {
  local pkgfile; local pkgfiles; local dep; local deps; local path; local args; local deps2;
  if [ -z "$dontAbsolutePkgconfig" ]; then
    header "Fixing up pkgconfig paths"
    for output in $outputs; do
      export PKG_CONFIG_PATH="$PKG_CONFIG_PATH${PKG_CONFIG_PATH:+:}${!output}/lib/pkgconfig"
    done

    pkgfiles="$(pkgconfigFiles)"
    for pkgfile in $pkgfiles; do
      deps="$(pkgconfigRequires "$pkgfile")"
      args=()
      for dep in $deps; do
        args+=("-e")
        path="$(pkgconfigPath $dep)"
        args+=("/^\\(Requires:\\|Requires\\.private:\\)/ s@\\(,\\| \\|:\\)$dep\\(,\\| \\|$\\)@\\1$path\\2@g")
      done
      if [ "${#args[@]}" -gt 0 ]; then
        sed -i "$pkgfile" "${args[@]}"
      fi

      deps2="$(pkgconfigRequires "$pkgfile")"
      for dep in $deps2; do
        if [ "${dep:0:1}" != "/" ]; then
          echo "Found a non-absolute dependency $dep in $pkgfile" >&2
          stopNest
          return 1
        fi
      done
    done

    stopNest
  fi
}

pkgconfigRequires() {
  local name;
  name="$1"
  if ! pkg-config --print-requires "$name" | awk '{print $1}'; then
    echo "Failed to enumerate all of the 'Requires:' dependencies $name" >&2
    return 1
  fi
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

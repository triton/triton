find_nautilus_extensions() {
  local -r nautiluspath='lib/nautilus/extensions-3.0/'

  if [ -d "$1/$nautiluspath" ]; then
    NAUTILUS_EXTENSION_DIRS+=("$1/$nautiluspath")
  fi
}

envHooks+=('find_nautilus_extensions')

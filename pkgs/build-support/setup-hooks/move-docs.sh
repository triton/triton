fixupOutputHooks+=(_moveDocs)

_mergeInto() {
  local src="$1"
  local dst="$2"

  if [ -d "$dst" ]; then
    cp -Trnv "$src" "$dst"
    rm -r "$src"
  else
    mkdir -p "$src"
    mv -v "$src" "$dst"
  fi
}

_moveToShare() {
  local d="$1"

  test -d "$prefix/$d" || return 0
  _mergeInto "$prefix/$d" "$prefix/share/$d"
}

_moveToOutput() {
  local d="$1"
  local output="$2"

  [ "$output" != "$prefix" ] || return 0
  [ -e "$prefix/share/$d" ] || return 0

  if [ -n "$output" ]; then
    _mergeInto "$prefix/share/$d" "$output/share/$d"
  else
    rm -rv "$prefix/share/$d"
  fi
}

_moveDocs() {
  echo "Fixing docs: $prefix" >&2

  local dir
  for dir in "${!docDirs[@]}"; do
    _moveToShare "$dir"
    _moveToOutput "$dir" "${docDirs["$dir"]}"
  done

  # Remove empty share directory.
  rmdir "$prefix"/share 2>/dev/null || true
}

declare -Ag docOutputs
if [ -z "${!docOutputs[*]}" ]; then
  docOutputs[man]="${outputs[man]-}"
  docOutputs[info]="${outputs[info]-}"
  docOutputs[doc]="${outputs[doc]-}"
  docOutputs[gtk-doc]="${outputs[doc]-}"
fi

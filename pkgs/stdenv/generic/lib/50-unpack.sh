# Finds and sets the srcRoot for a default build after unpacking has been
# completed
unpackFindRootDefault() {
  if [ -n "$srcRoot" ]; then
    return 0
  fi

  # If we end up with a single directory output we use that as our source
  # directory, otherwise we use the unpack directory
  local i
  for i in *; do
    if [ ! -d "$i" ] || [ -n "$srcRoot" ]; then
      srcRoot='.'
      break
    fi
    srcRoot="$i"
  done
}
if [ -z "$unpackFindRoot" ]; then
  unpackFindRoot='unpackFindRootDefault'
fi

unpackActionDefault() {
  if [ -z "$srcs" ]; then
    return 0
  fi

  # Unpacking should happen in its own directory to guarantee that
  # we don't have any build generated impurities mixed with the source.
  mkdir -p "$NIX_BUILD_TOP"/unpack
  pushd "$NIX_BUILD_TOP"/unpack >/dev/null

  # Unpack all source archives.
  local src
  for src in "${srcs[@]}"; do
    applyFile 'unpack' "$src"
  done

  runHook 'unpackFindRoot'

  # Make sure we have an absolute path before changing directories
  srcRoot="$(readlink -f "$srcRoot")"

  popd >/dev/null

  if [ -z "$srcRoot" ]; then
    echo "Failed to find a root source directory"
    exit 1
  fi

  echo "Source root is $srcRoot"
}
if [ -z "$unpackAction" ]; then
  unpackAction='unpackActionDefault'
fi

unpackPhase() {
  runHook 'preUnpack'

  runHook 'unpackAction'

  runHook 'postUnpack'
}

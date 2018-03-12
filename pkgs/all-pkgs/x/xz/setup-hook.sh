if ! type -t xzUnpackGenerator >/dev/null; then
  unpackCmdGenerators+=(xzUnpackGenerator)
fi

if ! type -t xzPatchGenerator >/dev/null; then
  patchCmdGenerators+=(xzUnpackGenerator)
fi

xzUnpackGenerator() {
  if ! [[ "$srcFile" =~ .xz$ ]]; then
    return 1
  fi

  cmd+=('|' '@out@/bin/xz' '-d')
  srcFile="${srcFile:0:-3}"
}

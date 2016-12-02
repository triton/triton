if ! type -t xzUnpackGenerator; then
  unpackCmdGenerators+=(xzUnpackGenerator)
fi

xzUnpackGenerator() {
  if ! [[ "$srcFile" =~ .xz$ ]]; then
    return 1
  fi
  
  cmd+=('|' '@out@/bin/xz' '-d')
  srcFile="${srcFile:0:-3}"
}

if ! type -t xzPatchGenerator; then
  patchCmdGenerators+=(xzPatchGenerator)
fi

xzPatchGenerator() {
  if ! [[ "$srcFile" =~ .xz$ ]]; then
    return 1
  fi

  cmd+=('|' '@out@/bin/xz' '-d')
  srcFile="${srcFile:0:-3}"
}

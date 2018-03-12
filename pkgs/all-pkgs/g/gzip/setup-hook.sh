if ! type -t gzUnpackGenerator >/dev/null; then
  unpackCmdGenerators+=(gzUnpackGenerator)
fi

if ! type -t gzPatchGenerator >/dev/null; then
  patchCmdGenerators+=(gzPatchGenerator)
fi

gzUnpackGenerator() {
  if ! [[ "$srcFile" =~ .gz$ ]]; then
    return 1
  fi

  cmd+=('|' '@out@/bin/gzip' '-d')
  srcFile="${srcFile:0:-3}"
}

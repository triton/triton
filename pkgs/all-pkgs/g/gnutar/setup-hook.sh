if ! type -t gnutarUnpackGenerator >/dev/null; then
  unpackCmdGenerators+=(gnutarUnpackGenerator)
fi

gnutarUnpackGenerator() {
  if ! [[ "$srcFile" =~ .tar$ ]]; then
    return 1
  fi

  cmd+=('|' '@out@/bin/tar' '-x')
  srcFile="${srcFile:0:-4}"
  canApply=1
}

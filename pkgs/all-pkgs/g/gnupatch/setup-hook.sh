if ! type -t gnupatchPatchGenerator >/dev/null; then
  patchCmdGenerators+=(gnupatchPatchGenerator)
fi

gnupatchPatchGenerator() {
  if ! [[ "$srcFile" =~ .patch$ ]]; then
    return 1
  fi

  local substituteArgs=()
  local key
  for key in "${!patchVars[@]}"; do
    substituteArgs+=(
      "--replace"
      "@$key@"
      "${patchVars["$key"]}"
    )
  done

  cmd+=('|' '@out@/bin/patch' '-d' "$srcRoot" '-p1')
  srcFile="${srcFile:0:-6}"
  canApply=1
}

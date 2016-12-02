patchActionDefault() {
  local patch
  for patch in "${patches[@]}"; do
    applyFile 'patch' "$patch"
  done
}
if [ -z "$patchAction" ]; then
  patchAction='patchActionDefault'
fi

patchPhase() {
  runHook 'prePatch'

  runHook 'patchAction'

  runHook 'postPatch'
}

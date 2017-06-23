_buildDirCheck() {
  if [ "${buildDirCheck-1}" != 1 ]; then
    return
  fi
  if [ ! -e "$prefix" ]; then
    return
  fi
  build-dir-check "$prefix"
}

_addHook() {
  local hasHook=0
  local hook
  for hook in "${fixupCheckOutputHooks[@]}"; do
    if [ "$hook" = "_buildDirCheck" ]; then
      hasHook=1
    fi
  done
  if [ "$hasHook" -eq "0" ]; then
    fixupCheckOutputHooks+=(_buildDirCheck)
  fi
}

_addHook

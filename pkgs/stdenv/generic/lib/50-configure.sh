configureBuildRoot() {
  if [ -z "$buildRoot" ]; then
    if [ -n "${createBuildRoot-true}" ]; then
      mkdir -p "$NIX_BUILD_TOP"/build
      buildRoot="$NIX_BUILD_TOP"/build
    else
      buildRoot="$srcRoot"
    fi
  fi
  buildRoot="$(readlink -f "$buildRoot")"
  echo "Using build root: $buildRoot"
}

defaultConfigureAction() {
  return 0
}
if [ -z "$configureAction" ]; then
  configureAction='defaultConfigureAction'
fi

configurePhase() {
  runHook 'preConfigure'

  runHook 'configureAction'

  runHook 'postConfigure'
}

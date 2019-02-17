# The waf executable must be located in the directory you want to
# extract it into.  This creates a symlink in the directory the
# source was extracted into and removes it after the build finishes.
wafUnpack() {
  ln -svf "$waf" "$wafForBuild"
}

wafConfigurePhase() {
  runHook 'preConfigure'

  if [ -n "${addPrefix-true}" ]; then
    wafFlagsArray+=("--prefix" "$prefix")
  fi

  wafFlagsArray+=('--jobs' "$NIX_BUILD_CORES")

  echo "configure flags: $wafFlags ${wafFlagsArray[@]}"
  "$wafPython" "$wafForBuild" configure $wafFlags "${wafFlagsArray[@]}"

  runHook 'postConfigure'
}

wafBuildPhase() {
  runHook 'preBuild'

  "$wafPython" "$wafForBuild" build --jobs $NIX_BUILD_CORES

  runHook 'postBuild'
}

wafInstallPhase() {
  runHook 'preInstall'

  "$wafPython" "$wafForBuild" install --jobs $NIX_BUILD_CORES

  runHook 'postInstall'
}

waf="${waf-@out@/bin/waf}"
wafPython="${wafPython-@PYTHON_EXE@}"
wafForBuild="${wafForBuild-waf}"
if [ -n "${wafConfigure-1}" ] ; then
  if [ -z "${wafVendored-}" ]; then
    preConfigurePhases+=('wafUnpack')
  fi
  configurePhase='wafConfigurePhase'
  buildPhase='wafBuildPhase'
  installPhase='wafInstallPhase'
fi

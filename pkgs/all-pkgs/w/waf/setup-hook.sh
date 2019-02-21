# The waf executable must be located in the directory you want to
# extract it into.  This creates a symlink in the directory the
# source was extracted into and removes it after the build finishes.
wafUnpack() {
  ln -svf "$waf" "$wafForBuild"
}

wafCommonFlags() {
  local phaseName="$1"
  actualWafFlags=()

  local parallelVar="${phaseName}Parallel"
  if [ -n "${!parallelVar-true}" ]; then
    actualWafFlags+=('--jobs' "${NIX_BUILD_CORES}")
  fi

  actualWafFlags+=($wafFlags)
  actualWafFlags+=("${wafFlagsArray[@]}")
  local flagsVar="waf${phaseName^}Flags"
  actualWafFlags+=(${!flagsVar})
  local arrayVar="waf${phaseName^}FlagsArray[@]"
  actualWafFlags+=("${!arrayVar}")
}

wafPrintFlags() {
  local phaseName="$1"

  echo "$phaseName waf flags:"

  local flag
  for flag in "${actualWafFlags[@]}"; do
    echo "  $flag"
  done
}

wafCall() {
  local phaseName="$1"

  wafCommonFlags "$phaseName"
  wafPrintFlags "$phaseName"
  "$wafPython" "$wafForBuild" "$phaseName" "${actualWafFlags[@]}"
}

wafConfigurePhase() {
  runHook 'preConfigure'

  if [ -n "${addPrefix-true}" ]; then
    wafConfigureFlagsArray+=("--prefix" "$prefix")
  fi

  wafCall 'configure'

  runHook 'postConfigure'
}

wafBuildPhase() {
  runHook 'preBuild'

  wafCall 'build'

  runHook 'postBuild'
}

wafInstallPhase() {
  runHook 'preInstall'

  wafCall 'install'

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

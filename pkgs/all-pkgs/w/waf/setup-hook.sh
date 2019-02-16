
find_waf() {
  type -P 'waf'
}

# The waf executable must be located in the directory you want to
# extract it into.  This creates a symlink in the directory the
# source was extracted into and removes it after the build finishes.
waf_unpack() {
  echo "$(find_waf)"
  ln -svf "$(find_waf)" "${wafExePath-waf}"
}

wafConfigurePhase() {
  eval "$preConfigure"

  if [ -n "${addPrefix-true}" ]; then
    wafFlagsArray+=("--prefix" "$prefix")
  fi

  wafFlagsArray+=('--jobs' "$NIX_BUILD_CORES")

  echo "configure flags: $wafFlags ${wafFlagsArray[@]}"
  @PYTHON_EXE@ "${wafExePath-waf}" configure $wafFlags "${wafFlagsArray[@]}"
  eval "$postConfigure"
}

wafBuildPhase() {
  eval "$preBuild"
  @PYTHON_EXE@ "${wafExePath-waf}" build --jobs $NIX_BUILD_CORES
  eval "$postBuild"
}

wafInstallPhase() {
  eval "$preInstall"
  @PYTHON_EXE@ "${wafExePath-waf}" install --jobs $NIX_BUILD_CORES
  eval "$postInstall"
}

remove_waf_link() {
  rm -fv "${wafExePath-waf}"
}

if [ -n "${wafSetupHook-true}" ] ; then
  if [ -z "${wafUseVendored-}" ]; then
    preConfigurePhases+=('waf_unpack')
  fi

  configurePhase='wafConfigurePhase'

  buildPhase='wafBuildPhase'

  installPhase='wafInstallPhase'

  if [ -z "${wafUseVendored-}" ]; then
    postPhases+=('remove_waf_link')
  fi
fi

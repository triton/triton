
find_waf() {
  type -P 'waf'
}

# The waf executable must be located in the directory you want to
# extract it into.  This creates a symlink in the directory the
# source was extracted into and removes it after the build finishes.
waf_unpack() {
  echo "$(find_waf)"
  ln -svf "$(find_waf)" "waf"
}

wafConfigurePhase() {
  eval "${preConfigure}"
  echo "configure flags: --prefix=${out} ${configureFlags}"
  ./waf configure --prefix=${out} ${configureFlags}
  eval "${postConfigure}"
}

wafBuildPhase() {
  eval "${preBuild}"
  ./waf build
  eval "${postBuild}"
}

wafInstallPhase() {
  eval "${preInstall}"
  ./waf install
  eval "${postInstall}"
}

remove_waf_link() {
  rm -fv 'waf'
}

if [ -n "${wafSetupHook-true}" ] ; then
  preConfigurePhases+=('waf_unpack')

  configurePhase='wafConfigurePhase'

  buildPhase='wafBuildPhase'

  installPhase='wafInstallPhase'

  postPhases+=('remove_waf_link')
fi

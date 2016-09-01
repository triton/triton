# https://swarm.workshop.perforce.com/view/guest/perforce_software/jam/src/Jam.html

jamBuildPhase() {
  eval "${preBuild}"
  jam \
    -s DESTDIR='/' \
    -s PREFIX="${out}" \
    -j $NIX_BUILD_CORES \
    -q \
    -f "${jamBase:-Jambase}"
  eval "${postBuild}"
}

jamInstallPhase() {
  eval "${preInstall}"
  jam \
    -s DESTDIR='/' \
    -s PREFIX="${out}" \
    -j $NIX_BUILD_CORES \
    -q \
    -f "${jamBase:-Jambase}" install
  eval "${postInstall}"
}

if [ -n "${jamSetupHook-true}" ] ; then
  buildPhase='jamBuildPhase'

  installPhase='jamInstallPhase'
fi

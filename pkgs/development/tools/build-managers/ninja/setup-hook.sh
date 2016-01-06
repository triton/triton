ninjaBuildPhase() {
  runHook preBuild
  echo "ninja flags: $makeFlags ${makeFlagsArray[@]} $buildFlags ${buildFlagsArray[@]}"
  ninja ${enableParallelBuilding:+-j${NIX_BUILD_CORES}} \
      $makeFlags "${makeFlagsArray[@]}" \
      $buildFlags "${buildFlagsArray[@]}"
  runHook postBuild
}

ninjaInstallPhase() {
  runHook preInstall
  mkdir -p "$prefix"
  echo "ninja install flags: $installTargets $makeFlags ${makeFlagsArray[@]} $installFlags ${installFlagsArray[@]}"
  ninja ${enableParallelBuilding:+-j${NIX_BUILD_CORES}} \
      $makeFlags "${makeFlagsArray[@]}" \
      $installFlags "${installFlagsArray[@]}" ${installTargets:-install}
  runHook postInstall
}


ninjaCheckPhase() {
  runHook preCheck
  echo "ninja check flags: $makeFlags ${makeFlagsArray[@]} $checkFlags ${checkFlagsArray[@]}"
  ninja ${enableParallelBuilding:+-j${NIX_BUILD_CORES}} \
      $makeFlags "${makeFlagsArray[@]}" \
      $checkFlags "${checkFlagsArray[@]}" ${checkTarget:-check}
  runHook postCheck
}


addNinjaParams() {
  local input; local ninja
  ninja=""
  for input in $nativeBuildInputs; do
    if [ -x "$input/bin/ninja" ]; then
      ninja="$input/bin/ninja"
      break
    fi
  done
  if [ -z "$ninja" ]; then
    echo "Ninja could not be found for installing into cmake">&2
    exit 1
  fi
  if [ -z "$ninjaInstalledCmake" ]; then
    export ninjaInstalledCmake=1
    cmakeFlagsArray+=("-DCMAKE_MAKE_PROGRAM=$ninja")
    cmakeFlagsArray+=("-GNinja")
  fi
}

if [ -z "$dontUseNinja" -a -z "$buildPhase" ]; then
  buildPhase=ninjaBuildPhase
fi
if [ -z "$dontUseNinja" -a -z "$checkPhase" ]; then
  checkPhase=ninjaCheckPhase
fi
if [ -z "$dontUseNinja" -a -z "$installPhase" ]; then
  installPhase=ninjaInstallPhase
fi
if [ -z "$dontUseNinja" ]; then
  envHooks+=(addNinjaParams)
fi

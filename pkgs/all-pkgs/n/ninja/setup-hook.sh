# Eventually combine with the upstream stdenv
ninjaCommonMakeFlags() {
    local phaseName
    phaseName=$1

    local parallelVar
    parallelVar="${phaseName}Parallel"

    actualMakeFlags=()
    if [ -n "$makefile" ]; then
        actualMakeFlags+=("-f" "$makefile")
    fi
    if [ -n "${!parallelVar-true}" ]; then
        actualMakeFlags+=("-j${NIX_BUILD_CORES}" "-l${NIX_BUILD_CORES}")
    fi
    actualMakeFlags+=($makeFlags)
    actualMakeFlags+=("${makeFlagsArray[@]}")
    local flagsVar
    flagsVar="${phaseName}Flags"
    actualMakeFlags+=(${!flagsVar})
    local arrayVar
    arrayVar="${phaseName}FlagsArray[@]"
    actualMakeFlags+=("${!arrayVar}")
}

ninjaBuildPhase() {
    runHook preBuild

    local actualMakeFlags
    ninjaCommonMakeFlags "build"
    printMakeFlags "build"
    TERM=dumb "$ninja" "${actualMakeFlags[@]}"

    runHook postBuild
}

ninjaCheckPhase() {
    runHook preCheck

    local actualMakeFlags
    ninjaCommonMakeFlags "check"
    actualMakeFlags+=(${checkTarget:-check})
    printMakeFlags "check"
    TERM=dumb "$ninja" "${actualMakeFlags[@]}"

    runHook postCheck
}

ninjaInstallPhase() {
    runHook preInstall

    mkdir -p "$prefix"

    local actualMakeFlags
    ninjaCommonMakeFlags "install"
    actualMakeFlags+=(${installTargets:-install})
    printMakeFlags "install"
    TERM=dumb "$ninja" "${actualMakeFlags[@]}"

    runHook postInstall
}

addNinjaParams() {
  if [ -z "$ninjaInstalledCmake" ]; then
    ninjaInstalledCmake=1
    cmakeFlagsArray+=("-DCMAKE_MAKE_PROGRAM=$ninja")
    cmakeFlagsArray+=("-GNinja")
  fi
  gypFormat="ninja"
}

ninja="${ninja-@out@/bin/ninja}"
if [ -n "${ninjaHook-1}" ]; then
  if [ -z "$buildPhase" ]; then
    buildPhase=ninjaBuildPhase
  fi
  if [ -z "$checkPhase" ]; then
    checkPhase=ninjaCheckPhase
  fi
  if [ -z "$installPhase" ]; then
    installPhase=ninjaInstallPhase
  fi
  envHooks+=(addNinjaParams)
fi

# Eventually combine with the upstream stdenv
sconsCommonMakeFlags() {
    local phaseName
    phaseName=$1

    local parallelVar
    parallelVar="parallel${phaseName^}"

    actualMakeFlags=()
    if [ -n "${!parallelVar-true}" ]; then
      actualMakeFlags+=("-j${NIX_BUILD_CORES}")
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

sconsBuildPhase() {
    runHook preBuild

    local actualMakeFlags
    sconsCommonMakeFlags "build"
    printMakeFlags "build"
    scons "${actualMakeFlags[@]}"

    runHook postBuild
}

sconsCheckPhase() {
    runHook preCheck

    local actualMakeFlags
    sconsCommonMakeFlags "check"
    actualMakeFlags+=(${checkTarget:-check})
    printMakeFlags "check"
    scons "${actualMakeFlags[@]}"

    runHook postCheck
}

sconsInstallPhase() {
    runHook preInstall

    mkdir -p "$prefix"

    local actualMakeFlags
    sconsCommonMakeFlags "install"
    actualMakeFlags+=(${installTargets:-install})
    printMakeFlags "install"
    scons "${actualMakeFlags[@]}"

    runHook postInstall
}

if [ -z "$dontUseScons" -a -z "$buildPhase" ]; then
  buildPhase=sconsBuildPhase
fi
if [ -z "$dontUseScons" -a -z "$checkPhase" ]; then
  checkPhase=sconsCheckPhase
fi
if [ -z "$dontUseScons" -a -z "$installPhase" ]; then
  installPhase=sconsInstallPhase
fi

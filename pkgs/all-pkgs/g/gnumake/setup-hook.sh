makeCommonFlags() {
  local phaseName="$1"
  local flagsVar="$2"

  local -n flagsRef="$flagsVar"
  local -n parallelRef="${phaseName}Parallel"
  local -n phaseFlagsRef="${phaseName}Flags"
  local -n phaseFlagsArrRef="${phaseName}FlagsArray"

  if [ -z "$buildRoot" ]; then
    if [ -z "$srcRoot" ]; then
      echo "Make requires a buildRoot or srcRoot to be set"
      exit 1
    fi
    buildRoot="$srcRoot"
  fi

  flagsRef+=("--directory=$buildRoot")
  if [ -n "$makefile" ]; then
    flagsRef+=("--file=$makefile")
  fi
  if [ -n "${parallelRef-1}" ]; then
    flagsRef+=("-j$NIX_BUILD_CORES" "-l$NIX_BUILD_CORES" "-O")
  fi
  flagsRef+=("SHELL=$bash") # Needed for https://github.com/NixOS/nixpkgs/pull/1354#issuecomment-31260409
  flagsRef+=($makeFlags)
  flagsRef+=("${makeFlagsArray[@]}")
  flagsRef+=($phaseFlagsRef)
  flagsRef+=("${phaseFlagsArrRef[@]}")
}

makeRun() {
  local phaseName="$1"
  local flagsVar="$2"

  local -n flagsRef="$flagsVar"

  printFlags "$phaseName" "$flagsVar"
  @out@/bin/make "${flagsRef[@]}"
}

makeBuildAction() {
  local flags=()
  makeCommonFlags 'build' flags
  makeRun 'build' flags
}
if [ -z "$buildAction" -o "$buildAction" = 'defaultBuildAction' ]; then
  buildAction='makeBuildAction'
fi

makeCheckAction() {
  local flags=()
  makeCommonFlags 'check' flags
  flags+=(${checkTarget:-check})
  makeRun 'check' flags
}
if [ -z "$checkAction" -o "$checkAction" = 'defaultCheckAction' ]; then
  checkAction='makeCheckAction'
fi

makeInstallAction() {
  local flags=()
  makeCommonFlags 'install' flags
  flags+=(${installTargets:-install})
  makeRun 'install' flags
}
if [ -z "$installAction" -o "$installAction" = 'defaultInstallAction' ]; then
  installAction='makeInstallAction'
fi

makeInstallCheckAction() {
  local flags=()
  makeCommonFlags 'installCheck' flags
  flags+=(${installCheckTargets:-installcheck})
  makeRun 'installCheck' flags
}
if [ -z "$installCheckAction" -o "$installCheckAction" = 'defaultInstallCheckAction' ]; then
  installCheckAction='makeInstallCheckAction'
fi

makeDistAction() {
  local flags=()
  makeCommonFlags 'dist' flags
  flags+=(${distTargets:-dist})
  makeRun 'dist' flags

  if [ "${copyDist-1}" == "1" ]; then
    mkdir -p "$out"/share/dist

    # Note: don't quote $tarballs, since we explicitly permit
    # wildcards in there.
    cp -pvd "$buildRoot"/${tarballs:-*.tar.*} "$out"/share/dist
  fi
}
if [ -z "$distAction" -o "$distAction" = 'defaultDistAction' ]; then
  distAction='makeDistAction'
fi

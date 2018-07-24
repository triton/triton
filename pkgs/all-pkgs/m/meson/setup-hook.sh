mesonConfigurePhase() {
    eval "$preConfigure"

    if [ -n "${addPrefix-true}" ]; then
      mesonFlagsArray+=(
        "--prefix" "$prefix"
      )
    fi

    # Configure the source and build directories
    if [ -z "$mesonSrcDir" ]; then
      mesonSrcDir="$(pwd)"
    fi
    if [ -z "$mesonBuildDir" ]; then
      if [ -n "${createMesonBuildDir-true}" ]; then
        mkdir -p "$TMPDIR"/build
        cd "$TMPDIR"/build
      fi
      mesonBuildDir="$(pwd)"
    fi

    # Build always Release, to ensure optimisation flags
    mesonFlagsArray+=(
      "--buildtype" "${mesonBuildType-release}"
    )

    echo "meson flags: $mesonFlags ${mesonFlagsArray[@]}"

    # Meson expect the local to be a unicode variant but
    # our default builder local is ANSI compatible. We need this
    # to be set during every stage of the build process since meson
    # is called from the generated build files.
    export LC_ALL="en_US.UTF-8"

    meson setup $mesonFlags "${mesonFlagsArray[@]}" \
      "${mesonSrcDir}" "${mesonBuildDir}"

    eval "$postConfigure"
}

mesonCheckPhase() {
    runHook 'preCheck'

    local actualMakeFlags
    actualMakeFlags=($checkFlags "${checkFlagsArray[@]}")
    printMakeFlags 'check'
    meson test "${actualMakeFlags[@]}"

    runHook 'postCheck'
}

mesonInstallPhase() {
    runHook 'preInstall'

    mkdir -p "$prefix"

    local actualMakeFlags
    actualMakeFlags=($installFlags "${installFlagsArray[@]}")
    actualMakeFlags+=('--no-rebuild')
    printMakeFlags 'install'
    meson install "${actualMakeFlags[@]}"

    runHook 'postInstall'
}

mesonFixup() {
  rm -rf "$prefix"/{share,libexec}/installed-tests
  rmdir "$prefix"/libexec >/dev/null 2>&1 || true
  rmdir "$prefix"/share >/dev/null 2>&1 || true
}

if [ -n "${mesonConfigure-true}" -a -z "$configurePhase" ]; then
  configurePhase=mesonConfigurePhase
  if [ -n "${mesonCheck-true}" ]; then
    checkPhase=mesonCheckPhase
  fi
  if [ -n "${mesonInstall-true}" ]; then
    installPhase=mesonInstallPhase
  fi
  fixupOutputHooks+=(mesonFixup)
fi

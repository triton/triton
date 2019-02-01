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

    mesonFlagsArray+=(
      # Build always Release, to ensure optimisation flags
      "--buildtype" "${mesonBuildType-release}"
      # Prefer using Link-Time Optimization
      "-Db_lto=true"
    )

    echo "meson flags: $mesonFlags ${mesonFlagsArray[@]}"

    "$meson" setup $mesonFlags "${mesonFlagsArray[@]}" \
      "${mesonSrcDir}" "${mesonBuildDir}"

    eval "$postConfigure"
}

mesonCheckPhase() {
    runHook 'preCheck'

    local actualMakeFlags
    actualMakeFlags=($checkFlags "${checkFlagsArray[@]}")
    printMakeFlags 'check'
    "$meson" test "${actualMakeFlags[@]}"

    runHook 'postCheck'
}

mesonInstallPhase() {
    runHook 'preInstall'

    mkdir -p "$prefix"

    local actualMakeFlags
    actualMakeFlags=($installFlags "${installFlagsArray[@]}")
    actualMakeFlags+=('--no-rebuild')
    printMakeFlags 'install'
    "$meson" install "${actualMakeFlags[@]}"

    runHook 'postInstall'
}

mesonFixup() {
  rm -rf "$prefix"/{share,libexec}/installed-tests
  rmdir "$prefix"/libexec >/dev/null 2>&1 || true
  rmdir "$prefix"/share >/dev/null 2>&1 || true
}

meson="${meson-@out@/bin/meson}"
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

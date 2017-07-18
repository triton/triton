mesonConfigurePhase() {
    eval "$preConfigure"

    if [ -z "$dontAddPrefix" ]; then
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

    # Meson requires a python executable for itself in the build directory
    echo "from subprocess import call; import sys; exit(call(['$(type -tP meson)'] + sys.argv[1:]))" \
      >"$mesonBuildDir"/meson

    # Build always Release, to ensure optimisation flags
    mesonFlagsArray+=(
      "--buildtype" "release"
    )

    echo "meson flags: $mesonFlags ${mesonFlagsArray[@]}"

    meson $mesonFlags "${mesonFlagsArray[@]}" "${mesonSrcDir}" "${mesonBuildDir}"

    eval "$postConfigure"
}

if [ -n "${mesonConfigure-true}" -a -z "$configurePhase" ]; then
  configurePhase=mesonConfigurePhase
fi

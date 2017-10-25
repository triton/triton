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

    # Meson requires a python executable for itself in the build directory
    for bin in $(ls "$(dirname "$(type -tP meson)")"/meson*); do
      echo "from subprocess import call; import sys; exit(call(['$bin'] + sys.argv[1:]))" \
        >"$mesonBuildDir"/"$(basename "$bin")"
    done

    # Build always Release, to ensure optimisation flags
    mesonFlagsArray+=(
      "--buildtype" "${mesonBuildType-release}"
    )

    echo "meson flags: $mesonFlags ${mesonFlagsArray[@]}"

    export LC_ALL='en_US.UTF-8'
    meson $mesonFlags "${mesonFlagsArray[@]}" "${mesonSrcDir}" "${mesonBuildDir}"

    eval "$postConfigure"
}

mesonFixup() {
  rm -rf "$prefix"/{share,libexec}/installed-tests
  rmdir "$prefix"/libexec >/dev/null 2>&1 || true
  rmdir "$prefix"/share >/dev/null 2>&1 || true
}

if [ -n "${mesonConfigure-true}" -a -z "$configurePhase" ]; then
  configurePhase=mesonConfigurePhase
  if [ -z "$checkTarget" ]; then
    checkTarget="test"
  fi
  fixupOutputHooks+=(mesonFixup)
fi

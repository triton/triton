mesonConfigurePhase() {
    eval "$preConfigure"

    if [ -z "$dontAddPrefix" ]; then
      mesonFlagsArray+=(
        "--prefix" "$prefix"
      )
    fi

    if [ -n "${createMesonBuildDir-true}" ]; then
      mesonDir="$(pwd)"
      mkdir -p "$TMPDIR"/build
      cd "$TMPDIR"/build
    fi

    # Build always Release, to ensure optimisation flags
    mesonFlagsArray+=(
      "--buildtype" "release"
    )

    echo "meson flags: $mesonFlags ${mesonFlagsArray[@]}"

    meson ${mesonDir:-.} $mesonFlags "${mesonFlagsArray[@]}"

    eval "$postConfigure"
}

if [ -n "${mesonConfigure-true}" -a -z "$configurePhase" ]; then
  configurePhase=mesonConfigurePhase
fi

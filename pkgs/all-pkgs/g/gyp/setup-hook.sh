gypConfigurePhase() {
  eval "$preConfigure"

  # Configure the source and build directories
  if [ -z "$gypSrcDir" ]; then
    gypSrcDir="$(pwd)"
  fi
  if [ -z "$gypBuildDir" ]; then
    if [ -n "${createGypBuildDir-true}" ]; then
      mkdir -p "$TMPDIR"/build
      cd "$TMPDIR"/build
    fi
    gypBuildDir="$(pwd)"
  fi

  gypFlagsArray+=(
    "--depth=src"
    "--format=${gypFormat-make}"
    "--config-dir=$gypSrcDir"
    "--toplevel-dir=$gypSrcDir"
    "--generator-output=$gypBuildDir"
    "-Goutput_dir=$gypBuildDir"
    $(find "$gypSrcDir" -name '*'.gypi -maxdepth 1 -exec echo --include={} \;)
    $(find "$gypSrcDir" -name '*'.gyp -maxdepth 1)
  )

  echo "gyp flags: $gypFlags ${gypFlagsArray[@]}"
  "$gyp" $gypFlags "${gypFlagsArray[@]}"

  gypBuildType="${gypBuildType-Release}"
  if [ -d "$gypBuildType" ]; then
    cd "$gypBuildType"
  else
    buildFlagsArray+=(
      "BUILDTYPE=$gypBuildType"
      "srcdir=$gypSrcDir"
    )
  fi

  eval "$postConfigure"
}

gyp="${gyp-@out@/bin/gyp}"
if [ -n "${gypConfigure-true}" -a -z "$configurePhase" ]; then
  configurePhase=gypConfigurePhase
fi

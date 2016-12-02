mesonConfigureAction() {
  configureBuildRoot

  if [ -n "${addPrefix-true}" ]; then
    mesonFlagsArray+=(
      "--prefix" "$prefix"
    )
  fi

  # Build always Release, to ensure optimisation flags
  mesonFlagsArray+=(
    "--buildtype" "${mesonBuildType-release}"
  )

  # Meson expect the local to be a unicode variant but
  # our default builder local is ANSI compatible. We need this
  # to be set during every stage of the build process since meson
  # is called from the generated build files.
  export LC_ALL="en_US.UTF-8"

  local actualFlags
  actualFlags=(
    $mesonFlags
    "${mesonFlagsArray[@]}"
  )

  printFlags "meson"
  LC_ALL='en_US.UTF-8' meson "${actualFlags[@]}" "${srcRoot}" "${buildRoot}"
}

mesonFixup() {
  rm -rf "$prefix"/{share,libexec}/installed-tests
  rmdir "$prefix"/libexec >/dev/null 2>&1 || true
  rmdir "$prefix"/share >/dev/null 2>&1 || true
}

if [ -n "${mesonConfigure-true}" -a "$configureAction" = "autotoolsConfigureAction" ]; then
  configureAction=mesonConfigureAction
  if [ -z "$checkTarget" ]; then
    checkTarget="test"
  fi
  fixupOutputHooks+=(mesonFixup)
fi

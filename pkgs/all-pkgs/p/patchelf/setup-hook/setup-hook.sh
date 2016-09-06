# This setup hook calls patchelf to automatically remove unneeded
# directories from the RPATH of every library or executable in every
# output.

fixupOutputHooks+=(patchELF)

patchELF() {
  if [ -z "$dontPatchELF" ]; then
    return 0
  fi

  header "patching ELF executables and libraries in $prefix"
  env
  @main@ "$prefix"
  stopNest
}

# This setup hook calls patchelf to automatically remove unneeded
# directories from the RPATH of every library or executable in every
# output.

fixupOutputHooks+=('if [ -z "$dontPatchELF" ]; then patchELF "$prefix"; fi')

patchELF() {
  header "patching ELF executables and libraries in $prefix"
  if [ -e "$prefix" ]; then
    # We need to know the path to all of the shared objects for the set of outputs.
    # Our outputs are allowed to reference the private shared objects of these outputs
    # since they are all part of the same package.
    # We want sodirs to be a global variable so that it can be referenced for each output fixed
    if [ -z "${sodirs+1}" ]; then
      echo "Finding shared object directories" >&2
      local output
      for output in $outputs; do
        sodirs="$(find "${!output}" -type f -a -name '*.so*' -exec dirname {} \;)"
      done
      sodirs="$(echo "$sodirs" | sort | uniq)"
      if [ "$NIX_DEBUG" = 1 ]; then
        echo "Shared Object Directories:" >&2
        for sodir in $sodirs; do
          echo "  $sodir" >&2
        done
      fi
    fi

    # For each of the execuatable or library fix the rpath
    local files
    files=($(find "$prefix" -type f -a \( -name '*.so*' -o -name '*.a*' -o -perm -0100 \)))
    for file in "${files[@]}"; do
      echo "Found binary: $file" >&2
      if readelf -S "$file" 2>&1 | grep -q '.dynamic'; then
        local oldrpath
        oldrpath="$(patchelf --print-rpath "$file")"

        # We want to remove any temporary directories from the path
        # We also want to add any shared object containing outputs to the rpath
        local notmprpath
        notmprpath="$(echo "$oldrpath" | tr ':' '\n' | sed "\,$TMPDIR,d")"
        if [ "${patchELFAddRpath-1}" = "1" ]; then
          rpath="$(echo -e "${sodirs}\n${notmprpath}" | sed '/^$/d' | tr '\n' ':' | sed 's,:$,\n,')"
        else
          rpath="$(echo "${notmprpath}" | tr '\n' ':' | sed 's,:$,\n,')"
        fi
        if [ "$NIX_DEBUG" = 1 ]; then
          echo "Old Rpath: $oldrpath" >&2
          echo "NoTmp Rpath: $notmprpath" >&2
          echo "New Rpath: $rpath" >&2
        fi
        echo "Removing temporary dirs: $file" >&2
        patchelf --set-rpath "$rpath" "$file"
        echo "Shrinking rpath: $file" >&2
        patchelf --shrink-rpath "$file"
        if [ "$NIX_DEBUG" = 1 ]; then
          echo "Shrunk Rpath: $(patchelf --print-rpath "$file")" >&2
        fi
      fi
    done
  fi
  stopNest
}

# This setup hook calls patchelf to automatically remove unneeded
# directories from the RPATH of every library or executable in every
# output.

fixupOutputHooks+=('if [ -z "$dontPatchELF" ]; then patchELF "$prefix"; fi')

patchelfPost() {
  case "$($CC -dumpmachine)" in
    powerpc*)
      PATCHELF_PAGE_SIZE=65536
      ;;
    i[0-9]86*|x86_64*)
      PATCHELF_PAGE_SIZE=4096
      ;;
    *)
      dontPatchELF=1
      ;;
  esac
}

postHooks+=(patchelfPost)

patchelf() {
  if [ -z "${PATCHELF_PAGE_SIZE-}" ]; then
    echo "No patchelf page size for ${CC-}"
    exit 1
  fi
  command patchelf --page-size "$PATCHELF_PAGE_SIZE" "$@"
}

# Wrapper to make logging a single statement
patchSingleBinary() {
  local output
  local ret=1
  if output="$(patchSingleBinaryWrapped "$@" 2>&1)"; then
    ret=0
  fi
  echo "$output" >&2
  return $ret
}

patchSingleBinaryWrapped() {
  local file="$1"
  echo "Attempting to patch possible binary: $file"

  # Check to see if we have a dynamic executable
  local oldrpath
  if ! oldrpath="$(patchelf --print-rpath "$file" 2>/dev/null)"; then
    echo "  Binary is not dynamic"
    return 0
  fi

  # We want to remove any temporary directories from the path
  local notmprpath
    notmprpath="$(echo "$oldrpath" | tr ':' '\n' | sed "\,$TMPDIR,d")"

  # Make sure the paths in the rpath exist
  local existrpath
  existrpath=""
  for rpath in $notmprpath; do
    if [ "$rpath" = '$ORIGIN' ] || [ -d "$(readlink -f "$rpath")" ]; then
      existrpath="$(printf "%s\n%s" "$existrpath" "$rpath")"
    fi
  done

  # We also want to add any shared object containing outputs to the rpath
  local rpathlist
  if [ "${patchELFAddRpath-1}" = "1" ] && [ -n "$sodirs" ]; then
    # We want to make sure we know exactly what new paths we need to add
    local extradirs
    findparams=$(patchelf --print-needed "$file" | awk '{ print "-or"; print "-name"; print $0}')
    extradirs="$(find ${sodirs} -mindepth 1 -maxdepth 1 \( -name 'no-such-file' $findparams \) -exec dirname {} \;)"
    rpathlist="$(printf "%s\n%s" "${extradirs}" "${existrpath}")"
  else
    rpathlist="${existrpath}"
  fi

  # Convert rpath lines into a semicolon separated string
  local rpath
  if [ -z "$rpathlist" ]; then
    rpath=""
  else
    rpath="$(echo "$rpathlist" | sed '/^$/d' | nl | sort -k 2 | uniq -f 1 | sort -n | cut -f 2 | tr '\n' ':' | sed -e 's,^:,,' -e 's,:$,\n,')"
  fi

  if [ "$NIX_DEBUG" = 1 ]; then
    echo "  Old Rpath: $oldrpath"
    echo "  NoTmp Rpath: $notmprpath"
    echo "  Exist Rpath: $existrpath"
    echo "  Extra Dirs: $extradirs"
    echo "  Rpathlist: $rpathlist"
    echo "  New Rpath: $rpath"
  fi

  if [ "$rpath" != "$oldrpath" ]; then
    echo "  Setting a new rpath"
    patchelf --set-rpath "$rpath" "$file"
  fi

  echo "  Shrinking rpath"
  patchelf --shrink-rpath "$file"

  if [ "$NIX_DEBUG" = 1 ]; then
    echo "  Shrunk Rpath: $(patchelf --print-rpath "$file")"
  fi
}

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
    local outstanding=0
    for file in "${files[@]}"; do
      if [ "$outstanding" -gt "$NIX_BUILD_CORES" ]; then
        wait
        outstanding=0
      fi
      patchSingleBinary "$file" &
      outstanding+=1
    done
    wait
  fi
  stopNest
}

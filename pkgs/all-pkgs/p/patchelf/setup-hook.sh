# This setup hook calls patchelf to automatically remove unneeded
# directories from the RPATH of every library or executable in every
# output.

fixupOutputHooks+=('if [ -z "$dontPatchELF" ]; then patchELF "$prefix"; fi')

patchELF() {
  header "patching ELF executables and libraries in $prefix"
  if [ -e "$prefix" ]; then
    while read file; do
      if readelf -S "$file" 2>&1 | grep -q '.dynamic'; then
        echo "Shrink rpath: $file" >&2
        patchelf --shrink-rpath "$file"
      fi
    done < <(find "$prefix" -type f -a \( -name "*.so*" -o -perm -0100 \))
  fi
  stopNest
}

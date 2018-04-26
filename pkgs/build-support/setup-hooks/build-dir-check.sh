# This setup hook, for each output, checks to make sure that
# no references to the build directory.

fixupCheckOutputHooks+=(_buildDirCheck)

_buildDirCheck() {
  if [ "${buildDirCheck-1}" != 1 ]; then
    return;
  fi
  if [ ! -e "$prefix" ]; then
    return;
  fi

  echo "Checking for build directory impurity in $prefix" >&2
  local output=""

  local -a links
  readarray -d $'\0' links < <(find "$prefix" -type l -print0)
  for link in "${links[@]}"; do
    output+="$(readlink "$link" | grep -H --label="$link" "$NIX_BUILD_TOP" || true)"
  done

  local -a files
  readarray -d $'\0' files < <(find "$prefix" -type f -print0)
  for file in "${files[@]}"; do
    local -a reader
    case "$file" in
      *.tgz|*.gz)
        reader=(gzip -d -c "$file")
        ;;
      *.tbz2|*.bz2)
        reader=(bzip2 -d -c "$file")
        ;;
      *.txz|*.xz)
        reader=(xz -d -c "$file")
        ;;
      *.tbr|*.br)
        reader=(brotli -d -c "$file")
        ;;
      *)
        reader=(cat "$file")
        ;;
    esac
    output+="$("${reader[@]}" | grep -H --label="$file" "$NIX_BUILD_TOP" || true)"
  done

  if [ -n "$output" ]; then
    echo "Found build directory impurity:" >&2
    echo "$output" >&2
    exit 1
  fi

  return 0
}

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
  local output
  output="$(grep -r "$NIX_BUILD_TOP" "$prefix" || true)"

  if [ -n "$output" ]; then
    echo "Found build directory impurity:" >&2
    echo "$output" >&2
    exit 1
  fi

  return 0
}

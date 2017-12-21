if ! type -t checkEmpty >/dev/null; then
  fixupCheckOutputHooks+=(checkEmpty)
fi

checkEmpty() {
  local file
  for file in "$TMPDIR"/empty/*; do
    echo "The empty builder directory should be empty, but we found $file"
    return 1
  done
}

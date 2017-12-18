# We define our outputs specifically to hold certain types of files
# This hook checks to make sure the build conforms to our output rules
# such that the placement of files occurs in the correct places.

if ! type -t checkOutputDir >/dev/null; then
  fixupCheckOutputHooks+=(checkOutputDir)
fi

checkOutputDir() {
  echo "Checking $output directories adhere to our rules..."

  if [ ! -e "$prefix" ]; then
    return 0
  fi

  if ! type -t "checkOutput${output^}" >/dev/null; then
    echo "Missing output directory definition for $output"
    echo "Expected to find a fuction 'checkOutput${output^}'"
    exit 1
  fi

  local file
  for file in $(find "$prefix"); do
    local fileIsValid=0
    runHook "checkOutput${output^}"
  done
}

checkOutputOut() {
  if [ "$fileIsValid" -eq "1" ]; then
    return 0
  fi

  case "$file" in
    "$prefix")
      return 0
      ;;
    */nix-support|*/nix-support/*)
      return 0
      ;;
  esac

  echo "Output 'out' should not contain a: $file"
  return 1
}


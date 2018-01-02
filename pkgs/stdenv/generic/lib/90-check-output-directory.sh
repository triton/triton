# We define our outputs specifically to hold certain types of files
# This hook checks to make sure the build conforms to our output rules
# such that the placement of files occurs in the correct places.

if ! type -t checkOutputDirMain >/dev/null; then
  fixupCheckOutputHooks+=(checkOutputDirMain)
fi

checkOutputDirMain() {
  echo "Checking $output directories adhere to our rules..."

  if [ ! -e "$prefix" ]; then
    return 0
  fi

  local file
  while read -d $'\0' file; do
    local fileIsValid=0
    runHook "checkOutputDir"
    if [ "$fileIsValid" -ne "1" ]; then
      echo "Output 'out' should not contain a: $file"
      return 1
    fi
  done < <(find "$prefix" -print0)
}

if ! type -t defaultCheckOutputDir >/dev/null; then
  checkOutputDirHooks+=(defaultCheckOutputDir)
fi
defaultCheckOutputDir() {
  if [ "$fileIsValid" -eq "1" ]; then
    return 0
  fi

  case "$file" in
    "$prefix"/bin|"$prefix"/bin/*[^/])
      if [ "$output" = "bin" ]; then
        fileIsValid=1
      fi
      if [ "$output" = "out" ] && ! hasOutput 'bin'; then
        fileIsValid=1
      fi
      ;;
    "$prefix"/lib)
      if [ "$output" = "lib" ]; then
        fileIsValid=1
      fi
      if [ "$output" = "dev" ]; then
        fileIsValid=1
      fi
      if [ "$output" = "out" ]; then
        fileIsValid=1
      fi
       ;;
    "$prefix"/lib/lib*[^/].so*[^/])
      if [ "$output" = "lib" ]; then
        fileIsValid=1
      fi
      if [ "$output" = "out" ] && ! hasOutput 'lib'; then
        fileIsValid=1
      fi
      ;;
    "$prefix"/lib/*)
      if [ "$output" = "dev" ]; then
        fileIsValid=1
      fi
      if [ "$output" = "out" ] && ! hasOutput 'dev'; then
        fileIsValid=1
      fi
      ;;
    "$prefix"/include|"$prefix"/include/*)
      if [ "$output" = "dev" ]; then
        fileIsValid=1
      fi
      if [ "$output" = "out" ] && ! hasOutput 'dev'; then
        fileIsValid=1
      fi
      ;;
    "$prefix"/libexec|"$prefix"/libexec/*)
      if [ "$output" = "bin" ]; then
        fileIsValid=1
      fi
      if [ "$output" = "out" ] && ! hasOutput 'bin'; then
        fileIsValid=1
      fi
      ;;
    "$prefix"/lib64)
      if [ -l "$file" ]; then
        if [ "$output" = "lib" ]; then
          fileIsValid=1
        fi
        if [ "$output" = "out" ] && ! hasOutput 'lib'; then
          fileIsValid=1
        fi
      else
        fileIsValid=0
      fi
      ;;
    "$prefix"/sbin)
      if [ -l "$file" ]; then
        if [ "$output" = "bin" ]; then
          fileIsValid=1
        fi
        if [ "$output" = "out" ] && ! hasOutput 'bin'; then
          fileIsValid=1
        fi
      else
        fileIsValid=0
      fi
      ;;
    "$prefix"/share)
      if [ "$output" = "man" ]; then
        fileIsValid=1
      fi
      if [ "$output" = "aux" ]; then
        fileIsValid=1
      fi
      if [ "$output" = "out" ] && ! hasOutput 'aux'; then
        fileIsValid=1
      fi
      ;;
    "$prefix"/share/man|"$prefix"/share/man/*)
      if [ "$output" = "man" ]; then
        fileIsValid=1
      fi
      if [ "$output" = "out" ] && ! hasOutput 'man'; then
        fileIsValid=1
      fi
      ;;
    "$prefix"/share/info|"$prefix"/share/info/*)
      if [ "$output" = "man" ]; then
        fileIsValid=1
      fi
      if [ "$output" = "out" ] && ! hasOutput 'man'; then
        fileIsValid=1
      fi
      ;;
    "$prefix"/share/*)
      if [ "$output" = "aux" ]; then
        fileIsValid=1
      fi
      if [ "$output" = "out" ] && ! hasOutput 'aux'; then
        fileIsValid=1
      fi
      ;;
    "$prefix")
      fileIsValid=1
      ;;
    "$prefix"/nix-support|"$prefix"/nix-support/*)
      fileIsValid=1
      ;;
  esac
}

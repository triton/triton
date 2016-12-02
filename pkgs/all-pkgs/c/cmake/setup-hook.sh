addCmakeParams() {
  addToSearchPath CMAKE_PREFIX_PATH "$1"
}
envHooks+=(addCMakeParams)

fixCmakeFiles() {
  # Replace occurences of /usr and /opt by /var/empty.
  echo "fixing cmake files..."
  find "$1" \( -type f -name "*.cmake" -o -name "*.cmake.in" -o -name CMakeLists.txt \) -print |
    while read fn; do
      sed -e 's^/usr\([ /]\|$\)^/var/empty\1^g' -e 's^/opt\([ /]\|$\)^/var/empty\1^g' < "$fn" > "$fn.tmp"
      mv "$fn.tmp" "$fn"
    done
}

cmakeConfigureAction() {
  if [ -n "${fixCmake-true}" ]; then
    fixCmakeFiles "$srcRoot"
  fi

  configureBuildRoot

  if [ -n "${addPrefix-true}" ]; then
    cmakeFlagsArray+=("-DCMAKE_INSTALL_PREFIX=$prefix")
  fi

  # Avoid cmake resetting the rpath of binaries, on make install
  # And build always Release, to ensure optimisation flags
  cmakeFlagsArray+=(
    "-DCMAKE_BUILD_TYPE=Release"
    "-DCMAKE_SKIP_BUILD_RPATH=ON"
  )

  local actualFlags
  actualFlags=(
    $cmakeFlags
    "${cmakeFlagsArray[@]}"
  )

  printFlags "cmake"
  cmake ${cmakeDir:-.} "${actualFlags[@]}"
}

makeCmakeFindLibs() {
  for flag in $NIX_CFLAGS_COMPILE $NIX_LDFLAGS; do
    case $flag in
      -I*)
        export CMAKE_INCLUDE_PATH="$CMAKE_INCLUDE_PATH${CMAKE_INCLUDE_PATH:+:}${flag:2}"
        ;;
      -L*)
        export CMAKE_LIBRARY_PATH="$CMAKE_LIBRARY_PATH${CMAKE_LIBRARY_PATH:+:}${flag:2}"
        ;;
    esac
  done
}

cmakeAddHookOnce() {
  local hookVar="$1"
  local targetHook="$2"

  local hook
  local hookArr="${hookVar}[@]"
  for hook in "${!hookArr}"; do
    if [ "$hook" = "$targetHook" ]; then
      return 0
    fi
  done
  eval "${hookVar}"'+=("$targetHook")'
}

if [ -n "${cmakeConfigure-true}" -a "$configureAction" = "autotoolsConfigureAction" ]; then
  configureAction=cmakeConfigureAction
fi

cmakeAddHookOnce envHooks addCmakeParams

# not using setupHook, because it could be a setupHook adding additional
# include flags to NIX_CFLAGS_COMPILE
cmakeAddHookOnce postHooks makeCmakeFindLibs

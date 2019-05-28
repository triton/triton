addCmakeParams() {
  addToSearchPath CMAKE_PREFIX_PATH $1
}

fixCmakeFiles() {
  # Replace occurences of /usr and /opt by /var/empty.
  echo "fixing cmake files..."
  find "$1" \( -type f -name "*.cmake" -o -name "*.cmake.in" -o -name CMakeLists.txt \) -exec \
    sed -e 's^/usr\([ /]\|$\)^/var/empty\1^g' -e 's^/opt\([ /]\|$\)^/var/empty\1^g' -i {} \;
}

cmakeConfigurePhase() {
  runHook 'preConfigure'

  if [ -n "${fixCmake-true}" ]; then
    fixCmakeFiles .
  fi

  if [ -n "${createCmakeBuildDir-true}" ]; then
    cmakeDir="$(pwd)"
    mkdir -p $TMPDIR/build
    cd $TMPDIR/build
  fi

  if [ -n "${addPrefix-true}" ]; then
    cmakeFlagsArray+=("-DCMAKE_INSTALL_PREFIX=$prefix")
  fi

  # Avoid cmake resetting the rpath of binaries, on make install
  # And build always Release, to ensure optimisation flags
  cmakeFlagsArray+=(
    "-DCMAKE_BUILD_TYPE=Release"
    "-DCMAKE_SKIP_BUILD_RPATH=ON"
  )

  echo "cmake flags: $cmakeFlags ${cmakeFlagsArray[@]}"
  cmake ${cmakeDir:-.} $cmakeFlags "${cmakeFlagsArray[@]}"

  runHook 'postConfigure'
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

cmake="${cmake-@out@/bin/cmake}"
if [ -z "${cmakeConfigured}" ]; then
  if [ -n "${cmakeHook-1}" -a -z "$configurePhase" ]; then
    configurePhase='cmakeConfigurePhase'
  fi
  envHooks+=(addCmakeParams)
  postHooks+=(makeCmakeFindLibs)
  cmakeConfigured=1
fi

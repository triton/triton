autotoolsLibtoolFix() {
  sed -i -e 's^eval sys_lib_.*search_path=.*^^' "$1"
}

autotoolsConfigureAction() {
  if [ -z "$configureScript" -a -x "$srcRoot"/configure ]; then
    configureScript="$srcRoot"/configure
  fi

  if [ ! -x "$configureScript" ]; then
    echo "Missing executable configure script: $configureScript" >&2
    exit 1
  fi
  configureScript="$(readlink -f "$configureScript")"
  echo "Using configure script: $configureScript"

  configureBuildRoot

  if [ -n "${fixLibtool-true}" ]; then
    find "$srcRoot" -iname "ltmain.sh" | while read i ; do
      echo "Fixing libtool script $i"
      autotoolsLibtoolFix "$i"
    done
  fi

  # Add --disable-dependency-tracking to speed up some builds.
  if [ -n "${addDisableDepTrack-true}" ]; then
    if grep -q dependency-tracking "$configureScript" 2>/dev/null; then
      configureFlagsArray+=("--disable-dependency-tracking")
    fi
  fi

  # By default, disable static builds.
  if [ -n "${disableStatic-true}" ]; then
    if grep -q enable-static "$configureScript" 2>/dev/null; then
      configureFlagsArray+=("--disable-static")
    fi
  fi

  # If we have multiple outputs, have the build do the right thing
  if [ "$outputs" != "out" ]; then
    configureFlagsArray+=("--prefix=$aux")
    configureFlagsArray+=("--exec-pefix=$bin")
    configureFlagsArray+=("--libdir=$dev/lib")
    configureFlagsArray+=("--includedir=$dev/include")
    configureFlagsArray+=("--mandir=$man/share/man")
    configureFlagsArray+=("--infodir=$man/share/info")
  else
    configureFlagsArray+=("--prefix=$out")
  fi

  # Use global state and configuration by default
  if [ -n "${useGlobalState-1}" ]; then
    configureFlagsArray+=("--sysconfdir=/etc")
    configureFlagsArray+=("--localstatedir=/var")
  fi

  local flags
  flags=(
    $configureFlags
    "${configureFlagsArray[@]}"
  )

  printFlags 'autotools' flags
  pushd "$buildRoot" >/dev/null
  $configureScript "${flags[@]}"
  popd >/dev/null
}

if [ -z "$configureAction" ] || [ "$configureAction" = 'defaultConfigureAction' ]; then
  configureAction='autotoolsConfigureAction'
fi

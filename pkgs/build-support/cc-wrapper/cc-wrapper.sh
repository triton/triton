#! @shell@ -e
path_backup="$PATH"
if [ -n "@coreutils@" ]; then
  PATH="@coreutils@/bin"
fi

if [ "${ccFixFlags-$NIX_ENFORCE_PURITY}" = "1" ]; then
  ccFixFlags=1
fi

if [ -n "$NIX_CC_WRAPPER_START_HOOK" ]; then
  source "$NIX_CC_WRAPPER_START_HOOK"
fi

if [ -z "$NIX_CC_WRAPPER_FLAGS_SET" ]; then
  source @out@/nix-support/add-flags.sh
fi

source @out@/nix-support/utils.sh

if [ -n "$NIX_DEBUG" ]; then
  echo "ccFixFlags: ${ccFixFlags:-0}" >&2
  echo "original flags to @prog@:" >&2
  for i in "$@"; do
    echo "  $i" >&2
  done
fi

# Figure out if linker flags should be passed.  GCC prints annoying
# warnings when they are not needed.
dontLink=0
shared=0
getVersion=0
nonFlagArgs=0

for i in "$@"; do
  if [ "$i" = -c ]; then
    dontLink=1
  elif [ "$i" = -shared ]; then
    shared=1
  elif [ "$i" = -S ]; then
    dontLink=1
  elif [ "$i" = -E ]; then
    dontLink=1
  elif [ "$i" = -E ]; then
    dontLink=1
  elif [ "$i" = -M ]; then
    dontLink=1
  elif [ "$i" = -MM ]; then
    dontLink=1
  elif [ "$i" = -x ]; then
    # At least for the cases c-header or c++-header we should set dontLink.
    # I expect no one use -x other than making precompiled headers.
    dontLink=1
  elif [ "${i:0:1}" != - ]; then
     nonFlagArgs=1
  fi
done

# If we pass a flag like -Wl, then gcc will call the linker unless it
# can figure out that it has to do something else (e.g., because of a
# "-c" flag).  So if no non-flag arguments are given, don't pass any
# linker flags.  This catches cases like "gcc" (should just print
# "gcc: no input files") and "gcc -v" (should print the version).
if [ "$nonFlagArgs" = 0 ]; then
    dontLink=1
fi

params=("$@")
new_params=()

if [ "${optFlags-$ccFixFlags}" = "1" ]; then
  new_params+=(@optFlags@)
fi

if [ "${ccPie-$ccFixFlags}" ] && [ "$dontLink" != "1" ] && [ "$shared" = "1" ]; then
  new_params+=("-pie")
fi

if [ "${ccFpic-$ccFixFlags}" ]; then
  new_params+=("-fPIC")
fi

if [ "${ccNoStrictOverflow-$ccFixFlags}" = "1" ]; then
  new_params+=("-fno-strict-overflow")
fi

if [ "${ccFortifySource-$ccFixFlags}" = "1" ]; then
  new_params+=("-D_FORTIFY_SOURCE=2")
fi

if [ "${ccStackProtector-$ccFixFlags}" = "1" ]; then
  new_params+=("-fstack-protector-strong")
fi

if [ "${ccOptimize-$ccFixFlags}" = "1" ]; then
  new_params+=("-O2")
fi

if [ "${ccDebug}" = "1" ]; then
  new_params+=("-g")
fi

# Remove any flags which may interfere with hardening
for (( i = 0; i < "${#params[@]}"; i++ )); do
  param="${params[$i]}"
  if [ "$ccFixFlags" = "1" ] && [[ "${param}" =~ ^-m(arch|tune|cpu)=native$ ]]; then
    continue
  fi
  if [ "$ccFixFlags" = "1" ] && [[ "${param}" =~ ^-g ]]; then
    continue
  fi
  if [ "${ccFortifySource-$ccFixFlags}" = "1" ] && [[ "${param}" =~ ^-(U|D)_FORTIFY_SOURCE ]]; then
    continue
  fi
  if [ "${ccNoStrictOverflow-$ccFixFlags}" = "1" ] && [[ "${param}" =~ ^-f(|no-)strict-overflow ]]; then
    continue
  fi
  if [ "${ccStackProtector-$ccFixFlags}" = "1" ] && [[ "${param}" =~ ^-f(|no-)stack-protector.* ]]; then
    continue
  fi
  if [ "${ccFpic-$ccFixFlags}" = "1" ] && [[ "${param}" =~ ^-f(|no-)(pic|PIC) ]]; then
    continue
  fi
  if [ "${ccPie-$ccFixFlags}" = "1" ] && [[ "${param}" =~ ^-f(|no-)(pie|PIE)$ ]]; then
    continue
  fi
  if [ "${ccOptimize-$ccFixFlags}" = "1" ] && [[ "${param}" =~ ^-O([0-9]|s|g|fast)$ ]]; then
    continue
  fi
  new_params+=("${param}")
done
params=("${new_params[@]}")

# Optionally filter out paths that are bad.
if [ -n "$NIX_STORE" ]; then
    rest=()
    n=0
    while [ $n -lt ${#params[*]} ]; do
        p=${params[n]}
        p2=${params[$((n+1))]}
        if [ "${p:0:3}" = -L/ ] && badPath "${p:2}"; then
            skip $p
        elif [ "$p" = -L ] && badPath "$p2"; then
            n=$((n + 1)); skip $p2
        elif [ "${p:0:3}" = -I/ ] && badPath "${p:2}"; then
            skip $p
        elif [ "$p" = -I ] && badPath "$p2"; then
            n=$((n + 1)); skip $p2
        elif [ "$p" = -isystem ] && badPath "$p2"; then
            n=$((n + 1)); skip $p2
        else
            rest+=("$p")
        fi
        n=$((n + 1))
    done
    params=("${rest[@]}")
fi

# Filter out any debug information referring to the NIX_BUILD_TOP
if [ "$NIX_ENFORCE_PURITY" = 1 ]; then
  if [ -z "$NIX_BUILD_TOP" ]; then
    echo "Missing NIX_BUILD_TOP" >&2
    exit 1
  fi
  if [ "${ccDebugMap-$ccFixFlags}" = "1" ]; then
    params+=("-fdebug-prefix-map=$NIX_BUILD_TOP=/no-such-path")
  fi
fi

if [[ "@prog@" = *++ ]]; then
  using_stdlib=1
  for arg in "$@"; do
    if [ "$arg" = "-nostdlib" ]; then
      using_stdlib=0
    fi
  done
  if [ "$using_stdlib" -eq "1" ]; then
    NIX_CFLAGS_COMPILE="$NIX_CFLAGS_COMPILE ${NIX_CXXSTDLIB_COMPILE-@default_cxx_stdlib_compile@}"
    NIX_CFLAGS_LINK="$NIX_CFLAGS_LINK $NIX_CXXSTDLIB_LINK"
  fi
fi

# Add the flags for the C compiler proper.
extraAfter=($NIX_CFLAGS_COMPILE)
extraBefore=()


if [ "$dontLink" != 1 ]; then
  # Add the flags that should only be passed to the compiler when
  # linking.
  extraAfter+=($NIX_CFLAGS_LINK)

  # Add the flags that should be passed to the linker (and prevent
  # `ld-wrapper' from adding NIX_LDFLAGS again).
  for i in $NIX_LDFLAGS_BEFORE; do
    extraBefore+=("-Wl,$i")
  done
  for i in $NIX_LDFLAGS; do
    if [ "${i:0:3}" = -L/ ]; then
      extraAfter+=("$i")
    else
      extraAfter+=("-Wl,$i")
    fi
  done
  export NIX_LDFLAGS_SET=1
fi

# As a very special hack, if the arguments are just `-v', then don't
# add anything.  This is to prevent `gcc -v' (which normally prints
# out the version number and returns exit code 0) from printing out
# `No input files specified' and returning exit code 1.
if [ "$*" = -v ]; then
    extraAfter=()
    extraBefore=()
fi

# Optionally print debug info.
if [ -n "$NIX_DEBUG" ]; then
  echo "new flags to @prog@:" >&2
  for i in "${params[@]}"; do
      echo "  $i" >&2
  done
  echo "extraBefore flags to @prog@:" >&2
  for i in ${extraBefore[@]}; do
      echo "  $i" >&2
  done
  echo "extraAfter flags to @prog@:" >&2
  for i in ${extraAfter[@]}; do
      echo "  $i" >&2
  done
fi

if [ -n "$NIX_CC_WRAPPER_EXEC_HOOK" ]; then
    source "$NIX_CC_WRAPPER_EXEC_HOOK"
fi

PATH="$path_backup"
exec @prog@ ${extraBefore[@]} "${params[@]}" "${extraAfter[@]}"

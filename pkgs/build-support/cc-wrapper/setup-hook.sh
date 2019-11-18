NIX@typefx@_CC='@out@'

export CC@typefx@='@targetfx@cc'
export CXX@typefx@='@targetfx@c++'
export CPP@typefx@='@targetfx@cpp'

if [ -n ${NIX_ENFORCE_PURITY+x} ]; then
  export CC_WRAPPER@typefx@_ENFORCE_PURITY="$NIX_ENFORCE_PURITY"
fi

@type@CCProg() {
  # Special case needed for things like LTO to work with
  # tools such as ar / nm / ranlib
  local prog="@targetfx@gcc-$1"
  if [ -e "@out@/bin/$prog" ]; then
    export ${1^^}@typefx@="$prog"
    return 0
  fi

  local prog="@targetfx@$1"
  if [ -e "@out@/bin/$prog" ]; then
    export ${1^^}@typefx@="$prog"
  fi
}

@type@CCProg ar
@type@CCProg ld
@type@CCProg nm
@type@CCProg ranlib
@type@CCProg readelf
@type@CCProg strip

@type@AddCVars() {
  if [ -e $1/nix-support/cc-wrapper-ignored ]; then
    return
  fi

  if [ -d $1/include ]; then
    export CC_WRAPPER@typefx@_STDINC+=" ${ccIncludeFlag:--isystem} $1/include"
  fi

  if [ -d $1/lib64 -a ! -L $1/lib64 ]; then
    export CC_WRAPPER@typefx@_LDFLAGS+=" -L$1/lib64"
  fi

  if [ -d $1/lib ]; then
    export CC_WRAPPER@typefx@_LDFLAGS+=" -L$1/lib"
  fi
}

@type@RestoreLTO() {
  if [ -n "${CC_WRAPPER@typefx@_CC_LTO_OLD+1}" ]; then
    export CC_WRAPPER@typefx@_CC_LTO="$CC_WRAPPER@typefx@_CC_LTO_OLD"
  else
    unset CC_WRAPPER@typefx@_CC_LTO
  fi
}

if [ -z "${nix_@type@_cc_done-}" ]; then
  nix_@type@_cc_done=1

  # TODO: Support native libraries and proper cross compiling
  if [ -z "@typefx@" ]; then
    envHooks+=(@type@AddCVars)
    postConfigureHooks+=(@type@RestoreLTO)
  fi
  if [ -n "${CC_WRAPPER@typefx@_CC_LTO+1}" ]; then
    CC_WRAPPER@typefx@_CC_LTO_OLD="$CC_WRAPPER@typefx@_CC_LTO"
  fi
  export CC_WRAPPER@typefx@_CC_LTO=

  # Add the output as an rpath, we should only ever do this for host binaries
  # and not for builder binaries since those should never be installed.
  if [ -z "@typefx@" ] && [ -n "${CC_WRAPPER_LD_ADD_RPATH-1}" ]; then
    rpathOutputs=()
    # We prefer libdirs over all others
    for output in $outputs; do
      if [ "${output:0:3}" = "lib" ]; then
        rpathOutputs+=("$output")
      fi
    done
    # Bin outputs can have dynamic libraries
    for output in $outputs; do
      if [ "${output:0:3}" = "bin" ]; then
        rpathOutputs+=("$output")
      fi
    done
    if [ "${#rpathOutputs[@]}" -eq "0" ]; then
      rpathOutputs+=("$defaultOutput")
    fi
    for output in "${rpathOutputs[@]}"; do
      export CC_WRAPPER_LDFLAGS_BEFORE+=" -rpath ${!output}/lib"
    done
  fi
fi

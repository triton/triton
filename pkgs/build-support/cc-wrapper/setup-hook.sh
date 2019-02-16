export NIX_CC=@out@

addCVars () {
  if [ -e $1/nix-support/cc-wrapper-ignored ]; then
    return
  fi

  if [ -d $1/include ]; then
    export NIX_CFLAGS_COMPILE+=" ${ccIncludeFlag:--isystem} $1/include"
  fi

  if [ -d $1/lib64 -a ! -L $1/lib64 ]; then
    export NIX_LDFLAGS+=" -L$1/lib64"
  fi

  if [ -d $1/lib ]; then
    export NIX_LDFLAGS+=" -L$1/lib"
  fi
}

envHooks+=(addCVars)

if [ -z "$crossConfig" ]; then
  export CC=@real_cc@
  export CXX=@real_cxx@
else
  export BUILD_CC=@real_cc@
  export BUILD_CXX=@real_cxx@
fi

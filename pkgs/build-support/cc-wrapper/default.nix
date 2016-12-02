# The Nixpkgs CC is not directly usable, since it doesn't know where
# the C library and standard header files are. Therefore the compiler
# produced by that package cannot be installed directly in a user
# environment and used from the command line. So we use a wrapper
# script that sets up the right environment variables so that the
# compiler and the linker just "work".

{ stdenv
, lib
, name ? ""

, impureLibc
, impurePrefix

, cc
, libc
, binutils
, coreutils
, shell ? stdenv.shell
, extraPackages ? [ ]
, extraBuildCommands ? ""
}:

assert (impureLibc != null && impurePrefix != null) || (impureLibc == null && impurePrefix == null);

let
  ccVersion = (builtins.parseDrvName cc.name).version;
  ccName = (builtins.parseDrvName cc.name).name;

  inherit (lib)
    head
    optionalString;

  inherit (lib.platforms)
    i686-linux
    x86_64-linux;
in
stdenv.mkDerivation {
  name =
    (if name != "" then name else ccName + "-wrapper") +
    (if cc != null && ccVersion != "" then "-" + ccVersion else "");

  preferLocalBuild = true;

  inherit
    cc
    libc
    binutils
    coreutils
    shell;

  optFlags =
    if cc.isGNU then
      if [ stdenv.targetSystem ] == x86_64-linux || [ stdenv.targetSystem ] == i686-linux then [
        "-mmmx"
        "-msse"
        "-msse2"
        "-msse3"
        "-mssse3"
        "-msse4"
        "-msse4.1"
        "-msse4.2"
        "-maes"
        "-mpclmul"
      ] else
        throw "Unknown optimization level for ${stdenv.targetSystem}"
    else  # TODO(wkennington): Figure out optimization flags for clang
      throw "Unkown optimization level for compiler and ${stdenv.targetSystem}";

  passthru = {
    inherit
      impureLibc
      impurePrefix;
    inherit (cc)
      isGNU
      isClang
      srcVerification;
    platformTuples = {
      "${head x86_64-linux}" = "x86_64-pc-linux-gnu";
      "${head x86_64-linux}-boot" = "x86_64-nixboot-linux-gnu";
      "${head i686-linux}" = "i686-pc-linux-gnu";
      "${head i686-linux}-boot" = "i686-nixboot-linux-gnu";
    };
  };

  buildCommand = ''
    mkdir -p $out/bin $out/nix-support

    wrap() {
      local dst="$1"
      local wrapper="$2"
      export prog="$3"
      substituteAll "$wrapper" "$out/bin/$dst"
      chmod +x "$out/bin/$dst"
    }
  '' + optionalString (impureLibc == null) ''
    dynamicLinker="$libc/lib/$dynamicLinker"
    echo $dynamicLinker > "$out"/nix-support/dynamic-linker

    # The dynamic linker is passed in `ldflagsBefore' to allow
    # explicit overrides of the dynamic linker by callers to gcc/ld
    # (the *last* value counts, so ours should come first).
    echo "-dynamic-linker" $dynamicLinker > "$out"/nix-support/libc-ldflags-before

    # Some of our tooling requires an understanding of the location of the glibc
    # headers so it can fix broken upstream includes. We add this to make the transition
    # to multiple-outputs more smooth.
    echo "$libc/include" > "$out"/nix-support/libc-include

    # The "-B$libc/lib/" flag is a quick hack to force gcc to link
    # against the crt1.o from our own glibc, rather than the one in
    # /usr/lib.  (This is only an issue when using an `impure'
    # compiler/linker, i.e., one that searches /usr/lib and so on.)
    #
    # Unfortunately, setting -B appears to override the default search
    # path. Thus, the gcc-specific "../includes-fixed" directory is
    # now longer searched and glibc's <limits.h> header fails to
    # compile, because it uses "#include_next <limits.h>" to find the
    # limits.h file in ../includes-fixed. To remedy the problem,
    # another -idirafter is necessary to add that directory again.
    echo "-B$libc/lib/ -idirafter $libc/include -idirafter $cc/lib/gcc/*/*/include-fixed" > "$out"/nix-support/libc-cflags

    echo "-L$libc/lib" > "$out"/nix-support/libc-ldflags

    echo "$libc" > "$out"/nix-support/orig-libc
  '' + (if impurePrefix != null then ''
    ccPath="${impurePrefix}/bin"
    ldPath="${impurePrefix}/bin"
  '' else ''
    echo "$cc" > "$out"/nix-support/orig-cc

    # GCC shows $cc/lib in `gcc -print-search-dirs', but not
    # $cc/lib64 (even though it does actually search there...)..
    # This confuses libtool.  So add it to the compiler tool search
    # path explicitly.
    if [ -e "$cc/lib64" -a ! -L "$cc/lib64" ]; then
      ccLDFlags+=" -L$cc/lib64"
      ccCFlags+=" -B$cc/lib64"
    fi
    ccLDFlags+=" -L$cc/lib"

    echo "$ccLDFlags" > $out/nix-support/cc-ldflags
    echo "$ccCFlags" > $out/nix-support/cc-cflags

    ccPath="$cc/bin"
    ldPath="$binutils/bin"

    # Propagate the wrapped cc so that if you install the wrapper,
    # you get tools like gcov, the manpages, etc. as well (including
    # for binutils and Glibc).
    echo $cc $binutils $libc > $out/nix-support/propagated-user-env-packages

    echo ${toString extraPackages} > $out/nix-support/propagated-native-build-inputs
  '') + ''
    # Create a symlink to as (the assembler).  This is useful when a
    # cc-wrapper is installed in a user environment, as it ensures that
    # the right assembler is called.
    if [ -e $ldPath/as ]; then
      ln -s $ldPath/as $out/bin/as
    fi

    wrap ld ${./ld-wrapper.sh} ''${ld:-$ldPath/ld}

    if [ -e $ldPath/ld.gold ]; then
      wrap ld.gold ${./ld-wrapper.sh} $ldPath/ld.gold
    fi

    if [ -e $ldPath/ld.bfd ]; then
      wrap ld.bfd ${./ld-wrapper.sh} $ldPath/ld.bfd
    fi

    export real_cc=cc
    export real_cxx=c++
    export default_cxx_stdlib_compile=""

    if [ -e $ccPath/gcc ]; then
      wrap gcc ${./cc-wrapper.sh} $ccPath/gcc
      ln -s gcc $out/bin/cc
      export real_cc=gcc
      export real_cxx=g++
    elif [ -e $ccPath/clang ]; then
      wrap clang ${./cc-wrapper.sh} $ccPath/clang
      ln -s clang $out/bin/cc
      export real_cc=clang
      export real_cxx=clang++
    fi

    if [ -e $ccPath/g++ ]; then
      wrap g++ ${./cc-wrapper.sh} $ccPath/g++
      ln -s g++ $out/bin/c++
    elif [ -e $ccPath/clang++ ]; then
      wrap clang++ ${./cc-wrapper.sh} $ccPath/clang++
      ln -s clang++ $out/bin/c++
    fi

    if [ -e $ccPath/cpp ]; then
      wrap cpp ${./cc-wrapper.sh} $ccPath/cpp
    fi
  '' + ''
    substituteAll ${./setup-hook.sh} $out/nix-support/setup-hook.tmp
    cat $out/nix-support/setup-hook.tmp >> $out/nix-support/setup-hook
    rm $out/nix-support/setup-hook.tmp

    substituteAll ${./add-flags} $out/nix-support/add-flags.sh
    cp -p ${./utils.sh} $out/nix-support/utils.sh
  '' + extraBuildCommands;

  # The dynamic linker has different names on different Linux platforms.
  dynamicLinker =
    if impureLibc == null then
      (if stdenv.targetSystem == "i686-linux" then "ld-linux.so.2" else
       if stdenv.targetSystem == "x86_64-linux" then "ld-linux-x86-64.so.2" else
       abort "Don't know the name of the dynamic linker for this platform.")
    else "";

  meta =
    let cc_ = if cc != null then cc else {}; in
    (if cc_ ? meta then removeAttrs cc.meta ["priority"] else {}) //
    { description =
        lib.attrByPath ["meta" "description"] "System C compiler" cc_
        + " (wrapper script)";
    };
}

{ stdenv
, bison
, cc
, fetchurl
, fetchTritonPatch
, gcc_lib_glibc
, glibc_progs
, libidn2_glibc
, linux-headers
, python3

, type ? "full"
}:

let
  inherit (stdenv.lib)
    boolEn
    boolWt
    optional
    optionals
    optionalAttrs
    optionalString;

  inherit (import ./common.nix { inherit fetchurl fetchTritonPatch; })
    src
    patches
    version;
self = stdenv.mkDerivation rec {
  name = "glibc-${version}";

  inherit
    src
    patches;

  nativeBuildInputs = [
    bison
    cc
    python3
  ] ++ optionals (type != "bootstrap") [
    glibc_progs
  ];

  prefix = placeholder "lib";

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
    "--enable-stackguard-randomization"
    "--enable-bind-now"
    "--enable-stack-protector=strong"
    "--enable-kernel=${linux-headers.channel}"
    "--disable-werror"
  ] ++ optionals (type != "bootstrap") [
    "libc_cv_use_default_link=yes"
  ];

  preConfigure = ''
    mkdir -v build
    cd build
    configureScript='../configure'
  '';

  preBuild = ''
    # We don't want to use the ld.so.cache from the system
    grep -q '#define USE_LDCONFIG' config.h
    echo '#undef USE_LDCONFIG' >>config.h

    # Don't build programs
    echo "build-programs=no" >>configparms

    export CC_WRAPPER_LD_ADD_RPATH
  '';

  preInstall = ''
    installFlags+=(
      "sysconfdir=$dev/etc"
      "localstatedir=$TMPDIR"
    )
  '';

  postInstall = ''
    mkdir -p "$dev"/lib

    pushd "$lib"/lib >/dev/null
    for file in $(find * -not -type d); do
      elf=1
      isELF "$file" || elf=0
      if [[ "$file" == *.so* && "$elf" == 1 ]]; then
        mkdir -p "$dev"/lib/"$(dirname "$file")"
        ln -sv "$lib"/lib/"$file" "$dev"/lib/"$file"
      else
        if [[ "$elf" == 0 ]] && grep -q 'ld script' "$file"; then
          sed -i "s,$lib,$dev,g" "$file"
        fi
        mv -v "$file" "$dev"/lib
      fi
    done
    popd >/dev/null
    mv "$dev"/lib/gconv-modules "$lib"/lib
    rm -r "$dev"/etc
    rm -r "$lib"/share
    mv "$lib"/include "$dev"

    mkdir -p "$dev"/nix-support
    echo "-D_FORTIFY_SOURCE=2" >>"$dev"/nix-support/cflags-before
    echo "-fno-strict-overflow" >>"$dev"/nix-support/cflags-before
    echo "-fstack-protector-strong" >>"$dev"/nix-support/cflags-before
    echo "-idirafter $dev/include" >>"$dev"/nix-support/stdinc
    echo "-B$dev/lib" >>"$dev"/nix-support/cflags
    dyld="$(echo "$lib"/lib/ld-*.so)"
    echo -n "$dyld" >>"$dev"/nix-support/dynamic-linker
    echo "-L$dev/lib" >>"$dev"/nix-support/ldflags
    echo "--enable-new-dtags" >>"$dev"/nix-support/ldflags-before
    echo "-z noexecstack" >>"$dev"/nix-support/ldflags-before
    echo "-z now" >>"$dev"/nix-support/ldflags-before
    echo "-z relro" >>"$dev"/nix-support/ldflags-before
  '' + optionalString (type != "bootstrap") ''
    # Ensure we always have a fallback C.UTF-8 locale-archive
    export LOCALE_ARCHIVE="$lib"/lib/locale/locale-archive
    mkdir -p "$(dirname "$LOCALE_ARCHIVE")"
    localedef -i C -f UTF-8 C.UTF-8
  '';

  # Patchelf will break our loader
  doPatchELF = false;

  # Adding RPaths breaks ld.so and other things and just isn't necessary here
  CC_WRAPPER_LD_ADD_RPATH = false;

  outputs = [
    "dev"
    "lib"
  ];

  outputChecks = {
    dev.allowedReferences = [ "dev" "lib" ];
    lib.allowedReferences = [ "lib" ];
  };

  passthru = {
    impl = "glibc";
    inherit version;
    cc_reqs = stdenv.mkDerivation {
      name = "glibc-cc_reqs-${version}";

      buildCommand = ''
        mkdir -p "$out"/lib
        ln -sv '${self.dev}'/lib/libc* "$out"/lib
        ln -sfv '${self.lib}'/lib/libc* "$out"/lib

        rm "$out"/lib/libc.so
        cp '${self.dev}'/lib/libc.so "$out"/lib
        chmod a+w "$out"/lib/libc.so
        echo "GROUP ( ${gcc_lib_glibc}/lib/libgcc_s.so ${libidn2_glibc}/lib/libidn2.so )" >>"$out"/lib/libc.so

        mkdir -p "$out"/nix-support
        echo "-L$out/lib" >"$out"/nix-support/cflags-link
      '';
    };
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux ++
      x86_64-linux ++
      powerpc64le-linux;
  };
};
in (self // { all = self.all ++ [ self.cc_reqs ];})

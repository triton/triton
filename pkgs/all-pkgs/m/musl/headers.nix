{ stdenv
, lib
, fetchurl
, musl_lib_gcc
}:

let
  inherit (lib)
    hasPrefix
    optionalString;

  inherit (musl_lib_gcc)
    src
    meta
    version;

  archs = {
    "powerpc64le-linux" = "powerpc64";
    "i686-linux" = "i386";
    "x86_64-linux" = "x86_64";
  };
in
(stdenv.override { cc = null; }).mkDerivation {
  name = "musl-headers-${version}";

  inherit
    src
    meta;

  configurePhase = ''
    true
  '';

  buildPhase = ''
    true
  '';

  makeFlags = [
    "prefix=${placeholder "out"}"
    "ARCH=${archs."${stdenv.targetSystem}"}"
  ];

  installTargets = [
    "install-headers"
  ];

  postInstall = ''
    mkdir -p "$out"/nix-support
    echo "-fno-strict-overflow" >>"$out"/nix-support/cflags-before
    echo "-fstack-protector-strong" >>"$out"/nix-support/cflags-before
    echo "-idirafter $out/include" >>"$out"/nix-support/stdinc
    touch "$out"/nix-support/dynamic-linker
    echo "--enable-new-dtags" >>"$out"/nix-support/ldflags-before
    echo "-z noexecstack" >>"$out"/nix-support/ldflags-before
    echo "-z now" >>"$out"/nix-support/ldflags-before
    echo "-z relro" >>"$out"/nix-support/ldflags-before
  '' + optionalString (hasPrefix "powerpc" stdenv.targetSystem) ''
    # TODO: Make 128-bit floats work
    #echo "-Wno-psabi" >>"$out"/nix-support/cflags-before
    #echo "-mlong-double-128" >>"$out"/nix-support/cflags-before
    #echo "-mabi=ieeelongdouble" >>"$out"/nix-support/cflags-before
    echo "-mlong-double-64" >>"$out"/nix-support/cflags-before
  '';

  dontStrip = true;
}

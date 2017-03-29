{ stdenv
, cmake
, fetchurl
, file
, python2
, rustc_bootstrap
, which

, jemalloc
, libffi
, llvm
, ncurses
, zlib

, channel ? "stable"
}:

let
  sources = import ./sources.nix {
    inherit fetchurl;
  };

  inherit (sources."${channel}")
    src
    srcVerification
    version;
in
stdenv.mkDerivation {
  name = "rustc-${version}";

  inherit src;

  nativeBuildInputs = [
    cmake
    file
    python2
    which
  ];

  buildInputs = [
    ncurses
    zlib
  ];

  # We don't directly run the cmake configure
  # The build system uses it for building compiler-rt
  cmakeConfigure = false;

  prePatch = ''
    # Fix not filtering out -L lines from llvm-config
    sed -i '\#if len(lib) == 1#a\        continue\n    if lib[0:2] == "-L":' src/etc/mklldeps.py

    # Fix llvm version constraints for 1.16.0
    sed -i 's,(3.\[7-9\]\*),(*),g' configure
  '';

  configureFlags = [
    "--disable-docs"
    "--release-channel=${channel}"
    "--enable-local-rust"
    "--local-rust-root=${rustc_bootstrap}"
    "--llvm-root=${llvm}"
    "--jemalloc-root=${jemalloc}/lib"
  ];

  buildFlags = [
    "VERBOSE=1"
  ];

  # Fix an issues with gcc6
  NIX_CFLAGS_COMPILE = "-Wno-error";

  NIX_LDFLAGS = "-L${libffi}/lib -lffi";

  passthru = {
    inherit srcVerification;
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

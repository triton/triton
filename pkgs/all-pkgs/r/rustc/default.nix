{ stdenv
, cargo
, cmake
, fetchurl
, file
, python2
, rustc
, which

, jemalloc
, libffi
, llvm_3-9
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

  local-rustc = stdenv.mkDerivation {
    name = "local-rustc-for-${version}";
    buildCommand = ''
      mkdir -p "$out"/bin
      ln -s "${cargo}"/bin/cargo "$out"/bin
      ln -s "${rustc}"/bin/rustc "$out"/bin
      ln -s "${rustc}"/lib "$out"
    '';
  };
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
  '';

  configureFlags = [
    "--disable-docs"
    "--disable-rustbuild"
    "--release-channel=${channel}"
    "--enable-local-rust"
    "--local-rust-root=${local-rustc}"
    "--llvm-root=${llvm_3-9}"
    "--jemalloc-root=${jemalloc}/lib"
  ];

  buildFlags = [
    "VERBOSE=1"
  ];

  # Fix an issues with gcc6
  NIX_CFLAGS_COMPILE = "-Wno-error";

  NIX_LDFLAGS = "-L${libffi}/lib -lffi";

  # FIXME
  buildDirCheck = false;

  passthru = {
    inherit
      srcVerification;
    bootstrap = rustc;
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

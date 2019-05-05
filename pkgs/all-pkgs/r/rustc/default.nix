{ stdenv
, cargo
, cmake
, fetchurl
, file
, python2
, rustc
, strace
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
    file
    local-rustc
    python2
    strace
    which
  ];

  buildInputs = [
    #ncurses
    #zlib
  ];

  configureFlags = [
    "--disable-docs"
    "--release-channel=${channel}"
    "--enable-local-rust"
    "--enable-local-rebuild"
    "--local-rust-root=${local-rustc}"
    "--llvm-root=${llvm}"
    "--jemalloc-root=${jemalloc}/lib"
  ];

  preBuild = ''
    sed -i 's,$(CFG_PYTHON),strace $(CFG_PYTHON),g' Makefile
    cat src/bootstrap/bootstrap.py
  '';

  buildFlags = [
    "VERBOSE=1"
  ];

  # Fix an issues with gcc6
  #NIX_CFLAGS_COMPILE = "-Wno-error";

  #NIX_LDFLAGS = "-L${libffi}/lib -lffi";

  # FIXME
  buildDirCheck = false;

  passthru = {
    inherit
      cargo
      rustc
      srcVerification
      version;
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

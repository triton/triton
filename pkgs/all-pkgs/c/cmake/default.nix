{ stdenv
, fetchTritonPatch
, fetchurl

, bzip2
, curl
, expat
, libarchive
, ncurses
, xz
, zlib
}:

let
  majorVersion = "3.8";
  minorVersion = "1";
  version = "${majorVersion}.${minorVersion}";
in
stdenv.mkDerivation rec {
  name = "cmake-${version}";

  src = fetchurl {
    url = "https://cmake.org/files/v${majorVersion}/cmake-${version}.tar.gz";
    multihash = "QmPrLLHUhxHADW5uGzvvjq2MFWKemeN9sAgesQGFaBieaV";
    sha256 = "ce5d9161396e06501b00e52933783150a87c33080d4bdcef461b5b7fd24ac228";
  };

  patches = [
    (fetchTritonPatch {
      rev = "78526c83438b5935a0d7516e3cbe0e3482495ffe";
      file = "cmake/search-path.patch";
      sha256 = "33cde1d7ed95194b699dfb82fe8340bcd234c4d51ce33e87c4c96e6c72acde53";
    })
  ];

  buildInputs = [
    bzip2
    curl
    expat
    libarchive
    ncurses
    xz
    zlib
  ];

  CMAKE_PREFIX_PATH = stdenv.lib.concatStringsSep ":" buildInputs;

  preConfigure = ''
    fixCmakeFiles .
    substituteInPlace Modules/Platform/UnixPaths.cmake \
      --subst-var-by libc ${stdenv.libc}
    configureFlagsArray+=("--parallel=$NIX_BUILD_CORES")
  '';

  cmakeConfigure = false;

  configureFlags = [
    "--docdir=/share/doc/${name}"
    "--mandir=/share/man"

    "--system-curl"
    "--system-expat"
    "--no-system-jsoncpp"  # Uses cmake as a build system
    "--system-zlib"
    "--system-bzip2"
    "--system-libarchive"
  ];

  setupHook = ./setup-hook.sh;
  selfApplySetupHook = true;

  meta = with stdenv.lib; {
    description = "Cross-Platform Makefile Generator";
    homepage = http://www.cmake.org/;
    license = licenses.free; # cmake
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

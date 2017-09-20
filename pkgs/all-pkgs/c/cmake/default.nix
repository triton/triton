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
  majorVersion = "3.9";
  minorVersion = "3";
  version = "${majorVersion}.${minorVersion}";
in
stdenv.mkDerivation rec {
  name = "cmake-${version}";

  src = fetchurl {
    url = "https://cmake.org/files/v${majorVersion}/cmake-${version}.tar.gz";
    multihash = "QmYyF9uSAmorZTYN6zynXk3pW9ncjYDASfHMokAmrKAPw1";
    sha256 = "8eaf75e1e932159aae98ab5e7491499545554be62a08cbcbc7c75c84b999f28a";
  };

  patches = [
    (fetchTritonPatch {
      rev = "e6b0d2af7e353e719ea3bb38f550111dab30cd91";
      file = "c/cmake/0001-Fix-search-paths.patch";
      sha256 = "e7c0b304f3c7340d22a44ecff64bd6d9f3997f12f437594f7ec59e5864a5e23a";
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

{ stdenv
, fetchTritonPatch
, fetchurl

, bzip2
, curl
, expat
, libarchive
, ncurses
, zlib
}:

let
  majorVersion = "3.4";
  minorVersion = "3";
  version = "${majorVersion}.${minorVersion}";
in

stdenv.mkDerivation rec {
  name = "cmake-${version}";

  src = fetchurl {
    url = "${meta.homepage}files/v${majorVersion}/cmake-${version}.tar.gz";
    sha256 = "1yl0z422gr7zfc638chifv343vx0ig5gasvrh7nzf7b15488qgxp";
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
    zlib
  ];

  CMAKE_PREFIX_PATH = stdenv.lib.concatStringsSep ":" buildInputs;

  preConfigure = ''
    source $setupHook
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

  meta = with stdenv.lib; {
    homepage = http://www.cmake.org/;
    description = "Cross-Platform Makefile Generator";
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}

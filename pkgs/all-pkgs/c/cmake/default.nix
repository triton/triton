{ stdenv
, cmake
, fetchTritonPatch
, fetchurl
, lib
, ninja

, bzip2
, curl
, expat
, jsoncpp
, libarchive
, libuv
, ncurses
, rhash
, xz
, zlib

, bootstrap ? false
}:

let
  inherit (lib)
    optionals
    optionalString;

  channel = "3.12";
  version = "${channel}.2";
in
stdenv.mkDerivation rec {
  name = "cmake${optionalString bootstrap "-bootstrap"}-${version}";

  src = fetchurl {
    url = "https://cmake.org/files/v${channel}/cmake-${version}.tar.gz";
    multihash = "QmW2VR8PzWyvhXLDmE4MyRceJC6GPkmbxTMhbrVPfXEE5h";
    hashOutput = false;
    sha256 = "0f97485799e51a7070cc11494f3e02349b0fc3a24cc12b082e737bf67a0581a4";
  };

  patches = [
    (fetchTritonPatch {
      rev = "e6b0d2af7e353e719ea3bb38f550111dab30cd91";
      file = "c/cmake/0001-Fix-search-paths.patch";
      sha256 = "e7c0b304f3c7340d22a44ecff64bd6d9f3997f12f437594f7ec59e5864a5e23a";
    })
  ];

  nativeBuildInputs = optionals (!bootstrap) [
    cmake
    ninja
  ];

  buildInputs = optionals (!bootstrap) [
    bzip2
    curl
    expat
    jsoncpp
    libarchive
    libuv
    ncurses
    rhash
    xz
    zlib
  ];

  postPatch = /* LibUV 1.21.0+ compat */ ''
    ! grep -q 'uv/version.h' Source/Modules/FindLibUV.cmake
    sed -i 's,uv-version.h,uv/version.h,' Source/Modules/FindLibUV.cmake
  '' + optionalString (!bootstrap) ''
    sed -i '/CMAKE_USE_SYSTEM_/s,OFF,ON,g' CMakeLists.txt
  '';

  preConfigure = ''
    substituteInPlace Modules/Platform/UnixPaths.cmake \
      --subst-var-by libc ${stdenv.libc}
  '' + optionalString bootstrap ''
    fixCmakeFiles .

    configureFlagsArray+=("--parallel=$NIX_BUILD_CORES")
  '';

  configureFlags = optionals bootstrap [
    "--no-system-libs"
    "--docdir=/share/doc/${name}"
    "--mandir=/share/man"
  ];

  # Cmake flags are only used by the final build of cmake
  cmakeFlags = optionals (!bootstrap) [
    "-DCMAKE_USE_SYSTEM_KWIML=OFF"
  ];

  setupHook = ./setup-hook.sh;
  selfApplySetupHook = true;
  cmakeConfigure = !bootstrap;

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      inherit (src)
        urls
        outputHash
        outputHashAlgo;
      fullOpts = { };
    };
  };

  meta = with lib; {
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

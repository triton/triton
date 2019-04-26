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

  channel = "3.14";
  version = "${channel}.3";
in
stdenv.mkDerivation rec {
  name = "cmake${optionalString bootstrap "-bootstrap"}-${version}";

  src = fetchurl {
    url = "https://cmake.org/files/v${channel}/cmake-${version}.tar.gz";
    multihash = "QmeiDYA6ApPjsuJjt3QNjwvWuf2rABHBP6KQEhY1uHtaQw";
    hashOutput = false;
    sha256 = "215d0b64e81307182b29b63e562edf30b3875b834efdad09b3fcb5a7d2f4b632";
  };

  patches = [
    (fetchTritonPatch {
      rev = "0b0552421abc55ceff6615bc3fcc3782eb132cd0";
      file = "c/cmake/0001-Remove-hardcoded-paths.patch";
      sha256 = "d6ffd2a315374821684fa7b76391ee665fa140a8eee8cf9f013595283f80158b";
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

  preConfigure = optionalString bootstrap ''
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
  cmakeHook = !bootstrap;

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

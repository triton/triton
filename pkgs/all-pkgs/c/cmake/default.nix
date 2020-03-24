{ stdenv
, cmake
, fetchTritonPatch
, fetchurl
, lib

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
}:

let
  channel = "3.17";
  version = "${channel}.0";
in
stdenv.mkDerivation rec {
  name = "cmake-${version}";

  src = fetchurl {
    url = "https://cmake.org/files/v${channel}/cmake-${version}.tar.gz";
    multihash = "QmWEHPF5uAvyv9CQCCkNbP1Kp5e76kmYsWtJKqhPpgq1eJ";
    hashOutput = false;
    sha256 = "b74c05b55115eacc4fa2b77a814981dbda05cdc95a53e279fe16b7b272f00847";
  };

  patches = [
    (fetchTritonPatch {
      rev = "0b0552421abc55ceff6615bc3fcc3782eb132cd0";
      file = "c/cmake/0001-Remove-hardcoded-paths.patch";
      sha256 = "d6ffd2a315374821684fa7b76391ee665fa140a8eee8cf9f013595283f80158b";
    })
  ];

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
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

    sed -i '/CMAKE_USE_SYSTEM_/s,OFF,ON,g' CMakeLists.txt
  '';

  cmakeFlags = [
    "-DCMAKE_USE_SYSTEM_KWIML=OFF"
  ];

  setupHook = ./setup-hook.sh;

  passthru = {
    inherit
      channel
      version;
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

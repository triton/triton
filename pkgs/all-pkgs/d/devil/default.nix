{ stdenv
, fetchurl
, cmake
, lib
, ninja

, jasper
, lcms
, libjpeg
, libpng
, libsquish
, libtiff
, zlib
}:

let
  version = "1.8.0";
in
stdenv.mkDerivation rec {
  name = "devil-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/openil/DevIL/${version}/"
      + "DevIL-${version}.tar.gz";
    sha256 = "0075973ee7dd89f0507873e2580ac78336452d29d34a07134b208f44e2feb709";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  buildInputs = [
    jasper
    lcms
    libjpeg
    libpng
    libsquish
    libtiff
    zlib
  ];

  cmakeFlags = [
    "-DIL_TESTS=OFF"
  ];

  postPatch = ''
    cd DevIL
  '';

  meta = with lib; {
    description = "DevIL image library";
    homepage = http://openil.sourceforge.net/;
    license = licenses.lgpl21;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

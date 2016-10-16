{ stdenv
, fetchurl
, lib

, giflib
, libjpeg
, libpng
, libtiff
, libwebp
, openjpeg
, zlib

, programs ? true
}:

let
  inherit (lib)
    boolEn
    boolWt;
in
stdenv.mkDerivation rec {
  name = "leptonica-1.73";

  src = fetchurl {
    url = "http://www.leptonica.org/source/${name}.tar.gz";
    multihash = "QmdsTL6sLfcSxH1ZPSbhwt6KNcYVDrQRbcqCT3rsGhbKgp";
    sha256 = "19e4335c674e7b78af9338d5382cc5266f34a62d4ce533d860af48eaa859afc1";
  };

  buildInputs = [
    giflib
    libjpeg
    libpng
    libtiff
    libwebp
    openjpeg
    zlib
  ];

  configureFlags = [
    "--${boolEn programs}-programs"
    "--${boolWt (zlib != null)}-zlib"
    "--${boolWt (libpng != null)}-libpng"
    "--${boolWt (openjpeg != null)}-jpeg"
    "--${boolWt (giflib != null)}-giflib"
    "--${boolWt (libtiff != null)}-libtiff"
    "--${boolWt (libwebp != null)}-libwebp"
    "--${boolWt (openjpeg != null)}-libopenjpeg"
  ];

  meta = with lib; {
    description = "Image processing and analysis library";
    homepage = http://www.leptonica.org/;
    # Its own license: http://www.leptonica.org/about-the-license.html
    license = licenses.free;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

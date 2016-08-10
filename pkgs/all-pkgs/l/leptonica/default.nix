{ stdenv
, fetchurl

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
  inherit (stdenv.lib)
    enFlag
    wtFlag;
in

stdenv.mkDerivation rec {
  name = "leptonica-1.73";

  src = fetchurl {
    url = "http://www.leptonica.org/source/${name}.tar.gz";
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
    (enFlag "programs" programs null)
    (wtFlag "zlib" (zlib != null) null)
    (wtFlag "libpng" (libpng != null) null)
    (wtFlag "jpeg" (openjpeg != null) null)
    (wtFlag "giflib" (giflib != null) null)
    (wtFlag "libtiff" (libtiff != null) null)
    (wtFlag "libwebp" (libwebp != null) null)
    (wtFlag "libopenjpeg" (openjpeg != null) null)
  ];

  meta = with stdenv.lib; {
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

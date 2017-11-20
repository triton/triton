{ stdenv
, fetchurl

, jbigkit
, libjpeg
, xz
, zlib
}:

let
  version = "4.0.9";
in
stdenv.mkDerivation rec {
  name = "libtiff-${version}";

  src = fetchurl {
    url = "http://download.osgeo.org/libtiff/tiff-${version}.tar.gz";
    multihash = "QmQCAPYk7dbLjNhJrQ9X8jvztSsLQ62hkqtEZqB8mBByVQ";
    sha256 = "6e7bdeec2c310734e734d19aae3a71ebe37a4d842e0e23dbb1b8921c0026cfcd";
  };

  buildInputs = [
    jbigkit
    libjpeg
    xz
    zlib
  ];

  meta = with stdenv.lib; {
    description = "Library and utilities for working with the TIFF image file format";
    homepage = http://www.remotesensing.org/libtiff/;
    license = licenses.libtiff;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

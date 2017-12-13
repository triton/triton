{ stdenv
, fetchTritonPatch
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

  patches = [
    (fetchTritonPatch {
      rev = "1573e5285d1efb2e011b02dc29cf545a2dfc0d23";
      file = "l/libtiff/CVE-2017-9935.patch";
      sha256 = "a18bd3e28931a723639e51bb3386ab6b710f5ca0930b6d85c7123e898190f31e";
    })
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

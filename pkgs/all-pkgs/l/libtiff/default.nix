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
    url = "https://download.osgeo.org/libtiff/tiff-${version}.tar.gz";
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
    (fetchTritonPatch {
      rev = "34ab40a8883e1c64d26c5c1833e76fc605275a4c";
      file = "l/libtiff/CVE-2017-18013.patch";
      sha256 = "60fcb294a55617cb0619be21733e10226e6f2bdbf1ff216df7b083f0d4580e58";
    })
    (fetchTritonPatch {
      rev = "34ab40a8883e1c64d26c5c1833e76fc605275a4c";
      file = "l/libtiff/CVE-2018-10963.patch";
      sha256 = "5324020b92212644b9a1d00e48c4992efbc94b83e4d72925ebe8d7774b61d1d7";
    })
    (fetchTritonPatch {
      rev = "34ab40a8883e1c64d26c5c1833e76fc605275a4c";
      file = "l/libtiff/CVE-2018-5784.patch";
      sha256 = "2a2ac96ce07320dfd08ae59b11973512cfeff4cb77ef4135194830a31a6ce92e";
    })
    (fetchTritonPatch {
      rev = "34ab40a8883e1c64d26c5c1833e76fc605275a4c";
      file = "l/libtiff/CVE-2018-7456.patch";
      sha256 = "a31f0ddc8ab7e2a95ccf7159b06d8da25e152852a0d327a741a1d8d6e5b67d89";
    })
    (fetchTritonPatch {
      rev = "34ab40a8883e1c64d26c5c1833e76fc605275a4c";
      file = "l/libtiff/CVE-2018-8905.patch";
      sha256 = "4dba6d7fe8b2f224f874027c858aa15ec8f8aebacea65f0afec677691e629a89";
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

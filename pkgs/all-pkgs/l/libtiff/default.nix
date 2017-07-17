{ stdenv
, fetchTritonPatch
, fetchurl

, jbigkit
, libjpeg
, xz
, zlib
}:

let
  version = "4.0.8";
in
stdenv.mkDerivation rec {
  name = "libtiff-${version}";

  src = fetchurl {
    url = "http://download.osgeo.org/libtiff/tiff-${version}.tar.gz";
    multihash = "QmVMYvrfQ6YZGXLJwZwpN8kdJKUmHdME2h3YXLxj57FwdK";
    sha256 = "59d7a5a8ccd92059913f246877db95a2918e6c04fb9d43fd74e5c3390dac2910";
  };

  buildInputs = [
    jbigkit
    libjpeg
    xz
    zlib
  ];

  patches = [
    (fetchTritonPatch {
      rev = "2b7cc8e18285cab70d998e70481ab7e9add51c03";
      file = "l/libtiff/CVE-2016-10095.patch";
      sha256 = "36063a31e9317c3745b5e03b210c948586ea469205b06d3dde2e1b2493f18d81";
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

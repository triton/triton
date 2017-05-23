{ stdenv
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

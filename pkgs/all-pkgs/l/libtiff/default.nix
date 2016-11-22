{ stdenv
, fetchurl

, jbigkit
, libjpeg
, xz
, zlib
}:

let
  version = "4.0.7";
in
stdenv.mkDerivation rec {
  name = "libtiff-${version}";

  src = fetchurl {
    url = "http://download.osgeo.org/libtiff/tiff-${version}.tar.gz";
    multihash = "Qmas7k26WaQrQyvdVfw3yHh8Gf5YMfyzLnNwGJu7TrZLda";
    sha256 = "9f43a2cfb9589e5cecaa66e16bf87f814c945f22df7ba600d63aac4632c4f019";
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

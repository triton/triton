{ stdenv
, fetchurl
, lib

, libjpeg
, libtiff
, zlib
}:

let
  inherit (lib)
    boolWt;

  version = "2.8";
in
stdenv.mkDerivation rec {
  name = "lcms-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/lcms/lcms/${version}/lcms2-${version}.tar.gz";
    sha256 = "66d02b229d2ea9474e62c2b6cd6720fde946155cd1d0d2bffdab829790a0fb22";
  };

  buildInputs = [
    libtiff
    libjpeg
    zlib
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--${boolWt (libjpeg != null)}-jpeg"
    "--${boolWt (libtiff != null)}-tiff"
    "--${boolWt (zlib != null)}-zlib"
    "--with-threads"  # POSIX threads
  ];

  meta = with lib; {
    description = "Color management engine";
    homepage = http://www.littlecms.com/;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

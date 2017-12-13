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

  version = "2.9";
in
stdenv.mkDerivation rec {
  name = "lcms-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/lcms/lcms/${version}/lcms2-${version}.tar.gz";
    sha256 = "48c6fdf98396fa245ed86e622028caf49b96fa22f3e5734f853f806fbc8e7d20";
  };

  buildInputs = [
    libtiff
    libjpeg
    zlib
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

{ stdenv
, fetchurl
, lib

, alsa-lib
}:

let
  version = "1.25.3";
in
stdenv.mkDerivation rec {
  name = "mpg123-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/mpg123/mpg123/${version}/${name}.tar.bz2";
    sha256 = "c24848dd1fcaf6900a2b1f5549996904f75fe6e05de982da655f8c626b375644";
  };

  buildInputs = [
    alsa-lib
  ];

  meta = with lib; {
    description = "Fast console MPEG Audio Player and decoder library";
    homepage = http://mpg123.org;
    license = licenses.lgpl21;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

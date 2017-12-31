{ stdenv
, fetchurl
, lib

, alsa-lib
}:

let
  version = "1.25.8";
in
stdenv.mkDerivation rec {
  name = "mpg123-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/mpg123/mpg123/${version}/${name}.tar.bz2";
    sha256 = "79da51efae011814491f07c95cb5e46de0476aca7a0bf240ba61cfc27af8499b";
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

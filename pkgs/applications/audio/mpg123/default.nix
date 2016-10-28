{stdenv, fetchurl, alsa-lib }:

let
  version = "1.23.8";
in
stdenv.mkDerivation rec {
  name = "mpg123-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/mpg123/mpg123/${version}/${name}.tar.bz2";
    sha256 = "de2303c8ecb65593e39815c0a2f2f2d91f708c43b85a55fdd1934c82e677cf8e";
  };

  buildInputs = [ alsa-lib ];

  meta = {
    description = "Fast console MPEG Audio Player and decoder library";
    homepage = http://mpg123.org;
    license = stdenv.lib.licenses.lgpl21;
    maintainers = [ ];
  };
}

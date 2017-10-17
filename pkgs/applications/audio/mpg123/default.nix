{ stdenv
, fetchurl
, lib

, alsa-lib
}:

let
  version = "1.25.7";
in
stdenv.mkDerivation rec {
  name = "mpg123-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/mpg123/mpg123/${version}/${name}.tar.bz2";
    sha256 = "31b15ebcf26111b874732e07c8e60de5053ee555eea15fb70c657a4f9f0344f3";
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

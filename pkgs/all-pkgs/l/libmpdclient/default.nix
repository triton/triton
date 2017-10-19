{ stdenv
, fetchurl
, doxygen
}:

let
  versionMajor = "2";
  versionMinor = "13";
  version = "${versionMajor}.${versionMinor}";
in
stdenv.mkDerivation rec {
  name = "libmpdclient-${version}";

  src = fetchurl {
    url = "https://www.musicpd.org/download/libmpdclient/${versionMajor}/"
        + "${name}.tar.xz";
    sha256 = "5115bd52bc20a707c1ecc7587e6389c17305348e2132a66cf767c62fc55ed45d";
  };

  nativeBuildInputs = [
    doxygen
  ];

  passthru = {
    inherit
      versionMajor
      versionMinor;
  };

  meta = with stdenv.lib; {
    description = "Client library for MPD (music player daemon)";
    homepage = http://www.musicpd.org/libs/libmpdclient/;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

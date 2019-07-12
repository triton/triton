{ stdenv
, fetchurl
, lib

, boost
, librevenge
}:

stdenv.mkDerivation rec {
  name = "libwpd-0.10.3";

  src = fetchurl {
    url = "mirror://sourceforge/libwpd/${name}.tar.xz";
    sha256 = "2465b0b662fdc5d4e3bebcdc9a79027713fb629ca2bff04a3c9251fdec42dd09";
  };

  buildInputs = [
    boost
    librevenge
  ];

  meta = with lib; {
    description = "A library for importing and exporting WordPerfect documents";
    homepage = http://libwpd.sourceforge.net/;
    license = licenses.lgpl21;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

{ stdenv
, fetchurl
, lib

, librevenge
, libwpd
, zlib
}:

stdenv.mkDerivation rec {
  name = "libwpg-0.3.3";

  src = fetchurl {
    url = "mirror://sourceforge/libwpg/${name}.tar.xz";
    sha256 = "99b3f7f8832385748582ab8130fbb9e5607bd5179bebf9751ac1d51a53099d1c";
  };

  buildInputs = [
    librevenge
    libwpd
  ];

  meta = with lib; {
    description = "C++ library to parse WPG";
    homepage = http://libwpg.sourceforge.net;
    license = licenses.lgpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

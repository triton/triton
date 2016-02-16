{ stdenv
, fetchurl

, bzip2
, glib
, gnutls
, ncurses
, sqlite
, zlib
}:

stdenv.mkDerivation rec {
  name = "ncdc-${version}";
  version = "1.19.1";

  src = fetchurl {
    url = "http://dev.yorhel.nl/download/ncdc-${version}.tar.gz";
    sha256 = "0iwx4b3x207sw11qqjfynpwnhryhixjzbgcy9l9zfisa8f0k7cm6";
  };

  buildInputs = [
    bzip2
    glib
    gnutls
    ncurses
    sqlite
    zlib
  ];

  meta = with stdenv.lib; {
    description = "ncurses direct connect client";
    homepage = http://dev.yorhel.nl/ncdc;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

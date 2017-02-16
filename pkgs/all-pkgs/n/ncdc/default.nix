{ stdenv
, fetchurl
, lib

, bzip2
, glib
, gnutls
, ncurses
, sqlite
, zlib
}:

stdenv.mkDerivation rec {
  name = "ncdc-1.20";

  src = fetchurl {
    url = "https://dev.yorhel.nl/download/${name}.tar.gz";
    sha256 = "8a998857df6289b6bd44287fc06f705b662098189f2a8fe95b1a5fbc703b9631";
  };

  buildInputs = [
    bzip2
    glib
    gnutls
    ncurses
    sqlite
    zlib
  ];

  configureFlags = [
    "--disable-git-version"
    "--without-geoip"
  ];

  meta = with lib; {
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

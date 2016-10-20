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
  name = "ncdc-1.19.1";

  src = fetchurl {
    url = "https://dev.yorhel.nl/download/${name}.tar.gz";
    sha256 = "a6b23381434a47f7134d9ebdf5658fd06768f9b5de498c43e0fa00d1c7229d47";
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

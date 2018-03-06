{ stdenv
, fetchurl
, lib

, ncurses
, pcre
, libpng
, zlib
, readline
}:

stdenv.mkDerivation rec {
  name = "slang-2.3.2";

  src = fetchurl {
    url = "https://www.jedsoft.org/releases/slang/${name}.tar.bz2";
    multihash = "QmZ7PE4f7zB4jmAFSqpKMTUbtrwr2e9z4pU22H5dhSkW57";
    sha1Confirm = "bbf7f2dcc14e7c7fca40868fd4b411a2bd9e2655";
    sha256 = "fc9e3b0fc4f67c3c1f6d43c90c16a5c42d117b8e28457c5b46831b8b5d3ae31a";
  };

  buildInputs = [
    ncurses
    pcre
    libpng
    zlib
    readline
  ];

  # Fix some hardcoded paths
  preConfigure = ''
    sed -i configure \
      -i src/sltermin.c \
      -e 's|/usr/lib/terminfo|${ncurses}/lib/terminfo|'
    sed -i src/Makefile.in -e 's|/bin/ln|ln|'
  '';

  configureFlags = [
    "--with-png=${libpng}"
    "--with-z=${zlib}"
    "--with-pcre=${pcre}"
    "--with-readline=${readline}"
  ];

  buildParallel = false;
  installParallel = false;

  meta = with lib; {
    description = "A library for creating robust software";
    homepage = http://www.jedsoft.org/slang/;
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [ ];
    platforms = with platforms;
      x86_64-linux;
  };
}

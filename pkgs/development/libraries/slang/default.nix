{ stdenv, fetchurl, ncurses, pcre, libpng, zlib, readline }:

stdenv.mkDerivation rec {
  name = "slang-2.3.1";
  src = fetchurl {
    url = "http://www.jedsoft.org/releases/slang/${name}.tar.bz2";
    sha1Confirm = "bfd47c83886665d30d358c30d154435ec7583a4d";
    sha256 = "a810d5da7b0c0c8c335393c6b4f12884be6fa7696d9ca9521ef21316a4e00f9d";
  };

  # Fix some wrong hardcoded paths
  preConfigure = ''
    sed -i -e "s|/usr/lib/terminfo|${ncurses}/lib/terminfo|" configure
    sed -i -e "s|/usr/lib/terminfo|${ncurses}/lib/terminfo|" src/sltermin.c
    sed -i -e "s|/bin/ln|ln|" src/Makefile.in
  '';
  configureFlags = "--with-png=${libpng} --with-z=${zlib} --with-pcre=${pcre} --with-readline=${readline}";
  buildInputs = [ncurses pcre libpng zlib readline];

  buildParallel = false;
  installParallel = false;

  meta = {
    description = "A multi-platform programmer's library designed to allow a developer to create robust software";
    homepage = http://www.jedsoft.org/slang/;
    license = stdenv.lib.licenses.gpl2Plus;
    platforms = stdenv.lib.platforms.all;
    maintainers = with stdenv.lib.maintainers; [ fuuzetsu ];
  };
}

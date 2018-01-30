{ stdenv, fetchurl, libwpg, libwpd, lcms, pkgconfig, librevenge, icu, boost, cppunit, zlib }:

stdenv.mkDerivation rec {
  name = "libcdr-0.1.4";

  src = fetchurl {
    url = "https://dev-www.libreoffice.org/src/${name}.tar.xz";
    sha256 = "e7a7e8b00a3df5798110024d7061fe9d1c3330277d2e4fa9213294f966a4a66d";
  };

  buildInputs = [ libwpg libwpd lcms librevenge icu boost cppunit zlib ];

  nativeBuildInputs = [ pkgconfig ];

  # Boost 1.59 compatability fix
  # Attempt removing when updating
  postPatch = ''
    sed -i 's,^CPPFLAGS.*,\0 -DBOOST_ERROR_CODE_HEADER_ONLY -DBOOST_SYSTEM_NO_DEPRECATED,' src/lib/Makefile.in
  '';

  configureFlags = if stdenv.cc.isClang
    then [ "--disable-werror" ] else null;

  CXXFLAGS="--std=gnu++0x"; # For c++11 constants in lcms2.h

  meta = {
    description = "A library providing ability to interpret and import Corel Draw drawings into various applications";
    homepage = http://www.freedesktop.org/wiki/Software/libcdr;
    platforms = stdenv.lib.platforms.all;
  };
}

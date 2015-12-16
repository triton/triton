{ stdenv, fetchurl, pkgconfig, libxml2, glib }:

stdenv.mkDerivation rec {
  name = "libcroco-0.6.10";

  src = fetchurl {
    url = "mirror://gnome/sources/libcroco/0.6/${name}.tar.xz";
    sha256 = "0v14ajhjdhsnlwp2q65629r53hgc0rrzr31653xw9xbpvw8nc1kj";
  };

  outputs = [ "out" "doc" ];

  configureFlags = stdenv.lib.optional stdenv.isDarwin "--disable-Bsymbolic";

  buildInputs = [ pkgconfig libxml2 glib ];

  meta = with stdenv.lib; {
    platforms = platforms.unix;
  };
}

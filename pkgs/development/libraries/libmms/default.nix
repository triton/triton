{ stdenv, fetchurl, glib }:

stdenv.mkDerivation rec {
  name = "libmms-0.6.4";

  src = fetchurl {
    url = "mirror://sourceforge/libmms/${name}.tar.gz";
    sha256 = "0kvhxr5hkabj9v7ah2rzkbirndfqdijd9hp8v52c1z6bxddf019w";
  };

  buildInputs = [ glib ];

  meta = {
    homepage = http://libmms.sourceforge.net;
    maintainers = [ stdenv.lib.maintainers.urkud ];
    platforms = stdenv.lib.platforms.all;
  };
}

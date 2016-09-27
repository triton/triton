{ fetchzip, stdenv, slang, popt }:

stdenv.mkDerivation rec {
  name = "newt-0.52.19";

  src = fetchzip {
    version = 2;
    url = "https://pagure.io/releases/newt/${name}.tar.gz";
    sha256 = "cc2d30acee5f78981f1e31bbb4c6fe30cf3ae25be2c1d8668f956cd8e43c9aa1";
  };

  patchPhase = ''
    sed -i -e s,/usr/bin/install,install, -e s,-I/usr/include/slang,, Makefile.in po/Makefile
  '';

  buildInputs = [ slang popt ];

  crossAttrs = {
    makeFlags = "CROSS_COMPILE=${stdenv.cross.config}-";
  };

  meta = {
    homepage = https://fedorahosted.org/newt/;
    description = "Library for color text mode, widget based user interfaces";

    license = stdenv.lib.licenses.lgpl2;
    platforms = stdenv.lib.platforms.linux;
    maintainers = [ stdenv.lib.maintainers.viric ];
  };
}

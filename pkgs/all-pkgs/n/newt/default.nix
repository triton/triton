{ stdenv, fetchurl, slang, popt }:

stdenv.mkDerivation rec {
  name = "newt-0.52.20";

  src = fetchurl {
    url = "https://pagure.io/releases/newt/${name}.tar.gz";
    sha256 = "8d66ba6beffc3f786d4ccfee9d2b43d93484680ef8db9397a4fb70b5adbb6dbc";
  };

  patchPhase = ''
    sed -i -e s,/usr/bin/install,install, -e s,-I/usr/include/slang,, Makefile.in po/Makefile
  '';

  buildInputs = [ slang popt ];

  crossAttrs = {
    makeFlags = "CROSS_COMPILE=${stdenv.cross.config}-";
  };

  meta = {
    homepage = https://pagure.io/newt;
    description = "Library for color text mode, widget based user interfaces";

    license = stdenv.lib.licenses.lgpl2;
    platforms = stdenv.lib.platforms.linux;
    maintainers = [ ];
  };
}

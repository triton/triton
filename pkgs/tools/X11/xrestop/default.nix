{ stdenv, fetchurl, xlibs, pkgconfig, ncurses }:

stdenv.mkDerivation rec {
  name = "xrestop-0.4";

  src = fetchurl {
    url = "mirror://gentoo/${name}.tar.gz";
    sha256 = "0mz27jpij8am1s32i63mdm58znfijcpfhdqq1npbmvgclyagrhk7";
  };

  buildInputs = [ pkgconfig xlibs.libX11 xlibs.libXres xlibs.libXext ncurses ];
}

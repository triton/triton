{ stdenv, fetchurl, autoreconfHook, autoconf-archive, xorg, python, libdrm, epoxy, mesa }:

stdenv.mkDerivation rec {
  name = "virglrenderer-0.2.0";

  src = fetchurl {
    url = "http://cgit.freedesktop.org/~airlied/virglrenderer/snapshot/${name}.tar.gz";
    sha256 = "0v9mg3ifja04xaw2clnm7na4wk16fmd3l2z11s0dfpa7w8wsarr3";
  };

  nativeBuildInputs = [ autoreconfHook autoconf-archive xorg.utilmacros python ];
  buildInputs = [ libdrm epoxy mesa xorg.libX11 ];

  postPatch = ''
    patchShebangs .
  '';

  meta = with stdenv.lib; {
    hompage = "http://cgit.freedesktop.org/~airlied/virglrenderer/";
    description = "virgil3d renderer standalone repo";
    license = licenses.gpl2;
    platforms = platforms.linux;
  };
}

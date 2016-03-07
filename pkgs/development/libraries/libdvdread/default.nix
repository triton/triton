{stdenv, fetchurl, libdvdcss}:

stdenv.mkDerivation rec {
  name = "libdvdread-${version}";
  version = "5.0.3";

  src = fetchurl {
    url = "http://get.videolan.org/libdvdread/${version}/${name}.tar.bz2";
    sha256 = "321cdf2dbdc83c96572bc583cd27d8c660ddb540ff16672ecb28607d018ed82b";
  };

  buildInputs = [ libdvdcss ];

  NIX_LDFLAGS = "-ldvdcss";

  postInstall = ''
    ln -s dvdread $out/include/libdvdread
  '';

  meta = {
    homepage = http://dvdnav.mplayerhq.hu/;
    description = "A library for reading DVDs";
    license = stdenv.lib.licenses.gpl2;
    maintainers = [ stdenv.lib.maintainers.wmertens ];
  };
}

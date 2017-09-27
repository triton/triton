{ stdenv, fetchurl, libjpeg, libtiff, librsvg }:

# TODO: https://github.com/barak/djvulibre

let
  version = "3.5.27";
in
stdenv.mkDerivation rec {
  name = "djvulibre-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/djvu/DjVuLibre/${version}/${name}.tar.gz";
    sha256 = "0psh3zl9dj4n4r3lx25390nx34xz0bg0ql48zdskhq354ljni5p6";
  };

  buildInputs = [ libjpeg libtiff librsvg ];

  meta = with stdenv.lib; {
    description = "A library and viewer for the DJVU file format for scanned images";
    homepage = http://djvu.sourceforge.net;
    license = licenses.gpl2;
    maintainers = with maintainers; [ urkud ];
    platforms = platforms.all;
  };
}

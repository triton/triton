{ stdenv
, fetchurl
, lib

, glib
, pango
, libx11
}:

stdenv.mkDerivation rec {
  name = "pangox-compat-0.0.2";

  src = fetchurl {
    url = "mirror://gnome/sources/pangox-compat/0.0/${name}.tar.xz";
    sha256 = "0ip0ziys6mrqqmz4n71ays0kf5cs1xflj1gfpvs4fgy2nsrr482m";
  };

  buildInputs = [
    glib
    pango
    libx11
  ];

  meta = with lib; {
    description = "A compatibility library for pango >1.30.*";
    homepage = http://www.pango.org/;
    license = licenses.lgpl2Plus;
    maintainers = with maintainers; [ ];
    platforms = with platforms;
      x86_64-linux;
  };
}

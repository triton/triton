{ stdenv
, fetchurl

, glib
, pango
, xorg
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
    xorg.libX11
  ];

  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    description = "A compatibility library for pango >1.30.*";
    homepage = http://www.pango.org/;
    license = licenses.lgpl2Plus;
    maintainers = with maintainers; [ ];
    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];
  };
}

{ fetchurl, stdenv, intltool, gettext, glib, libxml2, zlib, bzip2
, python, perl, gdk-pixbuf-core }:

with { inherit (stdenv.lib) optionals; };

stdenv.mkDerivation rec {
  name = "libgsf-1.14.36";

  src = fetchurl {
    url    = "mirror://gnome/sources/libgsf/1.14/${name}.tar.xz";
    sha256 = "71b7507f86c0f7c341bb362bdc7925a2ae286729be0bf5b8fd9581ffbbd62940";
  };

  nativeBuildInputs = [ intltool ];

  buildInputs = [ gettext bzip2 zlib python ]
    ++ stdenv.lib.optional doCheck perl;

  propagatedBuildInputs = [ libxml2 glib gdk-pixbuf-core ];

  doCheck = true;
  preCheck = "patchShebangs ./tests/";

  meta = with stdenv.lib; {
    description = "GNOME's Structured File Library";
    homepage    = http://www.gnome.org/projects/libgsf;
    license     = licenses.lgpl2Plus;
    maintainers = with maintainers; [ lovek323 ];
    platforms   = stdenv.lib.platforms.all;
  };
}

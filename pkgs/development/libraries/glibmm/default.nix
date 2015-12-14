{ stdenv, fetchurl, pkgconfig, glib, libsigcxx }:

let
  ver_maj = "2.46";
  ver_min = "3";
in
stdenv.mkDerivation rec {
  name = "glibmm-${ver_maj}.${ver_min}";

  src = fetchurl {
    url = "mirror://gnome/sources/glibmm/${ver_maj}/${name}.tar.xz";
    sha256 = "1kw65mlabwdjw86jybxslncbnnx40hcx4z6xpq9i4ymjvsnm91n7";
  };

  nativeBuildInputs = [ pkgconfig ];
  propagatedBuildInputs = [ glib libsigcxx ];

  #doCheck = true; # some tests need network

  meta = {
    description = "C++ interface to the GLib library";

    homepage = http://gtkmm.org/;

    license = stdenv.lib.licenses.lgpl2Plus;

    maintainers = with stdenv.lib.maintainers; [urkud raskin];
    platforms = stdenv.lib.platforms.unix;
  };
}

{ fetchurl, stdenv, clutter, gobject-introspection, gdk-pixbuf
, dbus, pythonPackages, libxml2, autoconf, libgee, glib, gtk3, pango
, libxklavier, xorg, gtk2, intltool, libxslt, at-spi2-core, automake }:

stdenv.mkDerivation rec {
  name = "caribou-${version}";
  versionMajor = "0.4";
  versionMinor = "19";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/caribou/${versionMajor}/${name}.tar.xz";
    sha256 = "0i2s2xy9ami3wslam15cajhggpcsj4c70qm7qddcz52z9k0x02rg";
  };

  buildInputs =
    [ glib gtk3 clutter at-spi2-core dbus
    pythonPackages.python automake gdk-pixbuf pango
      pythonPackages.pygobject3 libxml2 xorg.libXtst
      gtk2 intltool libxslt autoconf gobject-introspection ];

  propagatedBuildInputs = [ libgee libxklavier ];

  preBuild = ''
    patchShebangs .
    substituteInPlace libcaribou/Makefile.am --replace \
      "--shared-library=libcaribou.so.0" "--shared-library=$out/lib/libcaribou.so.0"
  '';

  meta = with stdenv.lib; {
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
    #maintainers = gnome3.maintainers;
  };

}

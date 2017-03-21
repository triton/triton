{ fetchurl, stdenv, clutter, gobject-introspection, gdk-pixbuf
, dbus, pythonPackages, libxml2, autoconf, libgee, glib, gtk3, pango
, libxklavier, xorg, gtk2, intltool, libxslt, at-spi2-core, automake }:

stdenv.mkDerivation rec {
  name = "caribou-${version}";
  versionMajor = "0.4";
  versionMinor = "21";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/caribou/${versionMajor}/${name}.tar.xz";
    sha256Url = "mirror://gnome/sources/caribou/${versionMajor}/"
      + "${name}.sha256sum";
    sha256 = "9c43d9f4bd30f4fea7f780d4e8b14f7589107c52e9cb6bd202bd0d1c2064de55";
  };

  buildInputs =
    [ glib gtk3 clutter at-spi2-core dbus
    pythonPackages.python automake gdk-pixbuf pango
      pythonPackages.pygobject libxml2 xorg.libXtst xorg.libX11
      gtk2 intltool libxslt autoconf gobject-introspection ];

  propagatedBuildInputs = [ libgee libxklavier ];

  preBuild = ''
    patchShebangs .
    substituteInPlace libcaribou/Makefile.am --replace \
      "--shared-library=libcaribou.so.0" "--shared-library=$out/lib/libcaribou.so.0"
  '';

  meta = with stdenv.lib; {
    platforms = with platforms;
      x86_64-linux;
    #maintainers = gnome3.maintainers;
  };

}

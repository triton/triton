{ stdenv, intltool, fetchurl, libgweather, libnotify
, pkgconfig, gtk3, glib, gsound
, makeWrapper, itstool, libcanberra, libtool
, librsvg, gdk-pixbuf, geoclue2, wrapGAppsHook
, gsettings-desktop-schemas, adwaita-icon-theme
, gnome-desktop, geocode-glib, libxml2
}:

stdenv.mkDerivation rec {
  name = "gnome-clocks-3.18.0";

  src = fetchurl {
    url = mirror://gnome/sources/gnome-clocks/3.18/gnome-clocks-3.18.0.tar.xz;
    sha256 = "ca0818ec89e3539201da6b5388365e3d66df815198beccc90e2be44c7822baa0";
  };

  doCheck = true;

  buildInputs = [ pkgconfig gtk3 glib intltool itstool libcanberra
                  gsettings-desktop-schemas makeWrapper
                  gdk-pixbuf librsvg adwaita-icon-theme
                  gnome-desktop geocode-glib geoclue2
                  libgweather libnotify libtool gsound libxml2
                ];

  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    homepage = https://wiki.gnome.org/Apps/Clocks;
    description = "Clock application designed for GNOME 3";
    maintainers = gnome3.maintainers;
    license = licenses.gpl2;
    platforms = platforms.linux;
  };
}

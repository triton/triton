{ stdenv
, fetchurl
, intltool
, itstool
, libtool

, adwaita-icon-theme
, gdk-pixbuf
, geoclue2
, geocode-glib
, glib
, gnome-desktop
, gsettings-desktop-schemas
, gsound
, gtk3
, libcanberra
, libgweather
, libnotify
, librsvg
, libxml2
, vala
}:

stdenv.mkDerivation rec {
  name = "gnome-clocks-${version}";
  versionMajor = "3.18";
  versionMinor = "0";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/gnome-clocks/${versionMajor}/${name}.tar.xz";
    sha256 = "ca0818ec89e3539201da6b5388365e3d66df815198beccc90e2be44c7822baa0";
  };

  nativeBuildInputs = [
    intltool
    itstool
    libtool
  ];

  buildInputs = [
    geoclue2
    geocode-glib
    glib
    gnome-desktop
    gsound
    gtk3
    libgweather
    libxml2
    vala
  ];

  configureFlags = [
    "--enable-nls"
    "--enable-rpath"
    "--enable-schemas-compile"
  ];

  doCheck = true;

  meta = with stdenv.lib; {
    description = "Clock application designed for GNOME 3";
    homepage = https://wiki.gnome.org/Apps/Clocks;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];
  };
}

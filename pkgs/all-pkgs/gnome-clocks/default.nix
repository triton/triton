{ stdenv
, fetchurl
, intltool
, itstool
, libtool

, geoclue2
, geocode-glib
, glib
, gnome-desktop
, gsound
, gtk3
, libgweather
, libxml2
, vala
}:

stdenv.mkDerivation rec {
  name = "gnome-clocks-${version}";
  versionMajor = "3.20";
  versionMinor = "0";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/gnome-clocks/${versionMajor}/${name}.tar.xz";
    sha256 = "e7a6da2ba3778fcfd77a6734f960319035370b942a3358089b7e712055e1bb17";
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
    platforms = with platforms;
      x86_64-linux;
  };
}

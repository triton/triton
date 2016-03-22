{ stdenv
, fetchurl
, gettext
, intltool

, adwaita-icon-theme
, cairo
, gdk-pixbuf
, glib
, gtk2
, gtk3
, librsvg
}:

with {
  inherit (stdenv.lib)
    enFlag;
};

stdenv.mkDerivation rec {
  name = "gnome-themes-standard-${version}";
  versionMajor = "3.20";
  #versionMinor = "0";
  version = "${versionMajor}"; #.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/gnome-themes-standard/${versionMajor}/" +
          "${name}.tar.xz";
    sha256 = "1cde84b34da310e6f2d403bfdbe9abb0798e5f07a1d1b4fde82af8e97edd3bdc";
  };

  nativeBuildInputs = [
    gettext
    intltool
  ];

  buildInputs = [
    adwaita-icon-theme
    cairo
    gdk-pixbuf
    glib
    gtk2
    gtk3
    librsvg
  ];

  configureFlags = [
    "--enable-glibtest"
    "--enable-nls"
    (enFlag "gtk3-engine" (gtk3 != null) null)
    (enFlag "gtk2-engine" (gtk2 != null) null)
  ];

  meta = with stdenv.lib; {
    description = "Standard Themes for GNOME Applications";
    homepage = https://git.gnome.org/browse/gnome-themes-standard/;
    license = licenses.lgpl21Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

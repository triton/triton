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

let
  inherit (stdenv.lib)
    enFlag;
in

stdenv.mkDerivation rec {
  name = "gnome-themes-standard-${version}";
  versionMajor = "3.20";
  versionMinor = "2";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/gnome-themes-standard/${versionMajor}/" +
          "${name}.tar.xz";
    sha256 = "9d0d9c4b2c9f9008301c3c1878ebb95859a735b7fd4a6a518802b9637e4a7915";
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

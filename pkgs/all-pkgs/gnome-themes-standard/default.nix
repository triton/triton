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
  versionMajor = "3.18";
  versionMinor = "0";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/gnome-themes-standard/${versionMajor}/" +
          "${name}.tar.xz";
    sha256 = "1jxss8kxszhf66vic9n1sagczm5amm0mgxpzyxyjna15q82fnip6";
  };

  configureFlags = [
    "--enable-glibtest"
    "--enable-nls"
    (enFlag "gtk3-engine" (gtk3 != null) null)
    (enFlag "gtk2-engine" (gtk2 != null) null)
  ];

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

  meta = with stdenv.lib; {
    description = "Standard Themes for GNOME Applications";
    homepage = https://git.gnome.org/browse/gnome-themes-standard/;
    license = licenses.lgpl21Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];
  };
}

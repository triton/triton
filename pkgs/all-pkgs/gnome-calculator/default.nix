{ stdenv
, fetchurl
, intltool
, itstool
, makeWrapper

, adwaita-icon-theme
, bash
, gdk-pixbuf
, glib
, gmp
, gnome-themes-standard
, gsettings-desktop-schemas
, gtk3
, gtksourceview
, librsvg
, libxml2
, mpfr
}:

stdenv.mkDerivation rec {
  name = "gnome-calculator-${version}";
  versionMajor = "3.18";
  versionMinor = "3";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/gnome-calculator/${versionMajor}/${name}.tar.xz";
    sha256 = "c376a4a14a3f7946b799b8458ac4cf2694735fc7c20e90cfda29e209439e32ff";
  };

  propagatedUserEnvPkgs = [
    gnome-themes-standard
  ];

  nativeBuildInputs = [
    intltool
    itstool
    makeWrapper
  ];

  buildInputs = [
    adwaita-icon-theme
    bash
    gdk-pixbuf
    glib
    gmp
    gsettings-desktop-schemas
    gtk3
    gtksourceview
    librsvg
    libxml2
    mpfr
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--enable-schemas-compile"
    "--enable-nls"
    "--disable-installed-tests"
  ];

  preFixup = ''
    wrapProgram $out/bin/gnome-calculator \
      --set 'GDK_PIXBUF_MODULE_FILE' "$GDK_PIXBUF_MODULE_FILE" \
      --prefix 'XDG_DATA_DIRS' : "$GSETTINGS_SCHEMAS_PATH" \
      --prefix 'XDG_DATA_DIRS' : "$XDG_ICON_DIRS"
  '';

  meta = with stdenv.lib; {
    description = "A calculator application for GNOME";
    homepage = https://wiki.gnome.org/Apps/Calculator;
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

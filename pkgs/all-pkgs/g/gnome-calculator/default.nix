{ stdenv
, fetchurl
, intltool
, itstool
, makeWrapper

, adwaita-icon-theme
, dconf
, gdk-pixbuf
, glib
, gmp
, gnome-themes-standard
, gsettings-desktop-schemas
, gtk3
, gtksourceview
, librsvg
, libsoup
, libxml2
, mpfr
}:

stdenv.mkDerivation rec {
  name = "gnome-calculator-${version}";
  versionMajor = "3.21";
  versionMinor = "90";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome-insecure/sources/gnome-calculator/${versionMajor}/"
      + "${name}.tar.xz";
    sha256Url = "mirror://gnome-secure/sources/gnome-calculator/${versionMajor}/"
      + "${name}.sha256sum";
    sha256 = "07408cb200ed1e1ef831a7afdd48f92e1ab4738a421d057fcc75ad134203bdc2";
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
    dconf
    gdk-pixbuf
    glib
    gmp
    gsettings-desktop-schemas
    gtk3
    gtksourceview
    librsvg
    libsoup
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
      --set 'GSETTINGS_BACKEND' 'dconf' \
      --prefix 'GIO_EXTRA_MODULES' : "$GIO_EXTRA_MODULES" \
      --prefix 'XDG_DATA_DIRS' : "$GSETTINGS_SCHEMAS_PATH" \
      --prefix 'XDG_DATA_DIRS' : "$out/share" \
      --prefix 'XDG_DATA_DIRS' : "$XDG_ICON_DIRS"
  '';

  meta = with stdenv.lib; {
    description = "A calculator application for GNOME";
    homepage = https://wiki.gnome.org/Apps/Calculator;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

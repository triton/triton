{ stdenv
, fetchurl
, intltool
, itstool
, libtool
, makeWrapper

, adwaita-icon-theme
, dconf
, gdk-pixbuf
, geoclue
, geocode-glib
, glib
, gnome-desktop
, gsettings-desktop-schemas
, gsound
, gtk3
, libgweather
, libxml2
, vala
}:

stdenv.mkDerivation rec {
  name = "gnome-clocks-${version}";
  versionMajor = "3.20";
  versionMinor = "1";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/gnome-clocks/${versionMajor}/${name}.tar.xz";
    sha256Url = "mirror://gnome/sources/gnome-clocks/${versionMajor}/${name}.sha256sum";
    sha256 = "92ad7b409c5118464af49ca28262ae43e9d377435ad2b10048b23e6e11ae476f";
  };

  nativeBuildInputs = [
    intltool
    itstool
    libtool
    makeWrapper
    vala
  ];

  buildInputs = [
    adwaita-icon-theme
    dconf
    gdk-pixbuf
    geoclue
    geocode-glib
    glib
    gnome-desktop
    gsettings-desktop-schemas
    gsound
    gtk3
    libgweather
    libxml2
  ];

  configureFlags = [
    "--enable-nls"
    "--enable-rpath"
    "--enable-schemas-compile"
  ];

  preFixup = ''
    wrapProgram $out/bin/gnome-clocks \
      --set 'GDK_PIXBUF_MODULE_FILE' "$GDK_PIXBUF_MODULE_FILE" \
      --set 'GSETTINGS_BACKEND' 'dconf' \
      --prefix 'GIO_EXTRA_MODULES' : "$GIO_EXTRA_MODULES" \
      --prefix 'XDG_DATA_DIRS' : "$GSETTINGS_SCHEMAS_PATH" \
      --prefix 'XDG_DATA_DIRS' : "$out/share" \
      --prefix 'XDG_DATA_DIRS' : "$XDG_ICON_DIRS"
  '';

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

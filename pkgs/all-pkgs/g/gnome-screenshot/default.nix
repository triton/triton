{ stdenv
, fetchurl
, intltool
, itstool
, makeWrapper

, adwaita-icon-theme
, dconf
, gdk-pixbuf
, glib
, gsettings-desktop-schemas
, gtk3
, libcanberra
, xorg
}:

stdenv.mkDerivation rec {
  name = "gnome-screenshot-${version}";
  versionMajor = "3.20";
  versionMinor = "1";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/gnome-screenshot/${versionMajor}/"
      + "${name}.tar.xz";
    sha256Url = "mirror://gnome/sources/gnome-screenshot/${versionMajor}/"
      + "${name}.sha256sum";
    sha256 = "06a89b6887146cdbbeb64adf11bdae21acf22b0422337041c66eedb21ef7e143";
  };

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
    gsettings-desktop-schemas
    gtk3
    libcanberra
    xorg.libX11
    xorg.libXext
  ];

  configureFlags = [
    "--enable-nls"
    "--enable-schemas-compile"
  ];

  preFixup = ''
    wrapProgram $out/bin/gnome-screenshot \
      --set 'GDK_PIXBUF_MODULE_FILE' "$GDK_PIXBUF_MODULE_FILE" \
      --set 'GSETTINGS_BACKEND' 'dconf' \
      --prefix 'GIO_EXTRA_MODULES' : "$GIO_EXTRA_MODULES" \
      --prefix 'XDG_DATA_DIRS' : "$GSETTINGS_SCHEMAS_PATH" \
      --prefix 'XDG_DATA_DIRS' : "$out/share" \
      --prefix 'XDG_DATA_DIRS' : "$XDG_ICON_DIRS"
  '';

  doCheck = true;

  meta = with stdenv.lib; {
    description = "Utility used in the GNOME desktop environment for screenshots";
    homepage = http://en.wikipedia.org/wiki/GNOME_Screenshot;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

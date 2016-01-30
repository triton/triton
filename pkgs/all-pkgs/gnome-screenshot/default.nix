{ stdenv
, fetchurl
, intltool
, itstool
, makeWrapper

, adwaita-icon-theme
, bash
, gdk-pixbuf
, glib
, gnome-themes-standard
, gsettings-desktop-schemas
, gtk3
, libcanberra
, librsvg
, xorg
}:

stdenv.mkDerivation rec {
  name = "gnome-screenshot-${version}";
  versionMajor = "3.18";
  versionMinor = "0";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/gnome-screenshot/${versionMajor}/" +
          "${name}.tar.xz";
    sha256 = "eba64dbf4acf0ab8222fec549d0a4f2dd7dbd51c255e7978dedf1f5c06a98841";
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
    gsettings-desktop-schemas
    gtk3
    libcanberra
    librsvg
    xorg.libX11
    xorg.libXext
  ];

  configureFlags = [
    "--enable-nls"
    "--enable-schemas-compile"
  ];

  NIX_CFLAGS_COMPILE = [
    "-I${glib}/include/gio-unix-2.0"
  ];

  preFixup = ''
    wrapProgram "$out/bin/gnome-screenshot" \
      --set GDK_PIXBUF_MODULE_FILE "$GDK_PIXBUF_MODULE_FILE" \
      --prefix XDG_DATA_DIRS : "${gtk3}/share" \
      --prefix XDG_DATA_DIRS : "${gnome-themes-standard}/share" \
      --prefix XDG_DATA_DIRS : "$out/share" \
      --prefix XDG_DATA_DIRS : "$XDG_ICON_DIRS" \
      --prefix XDG_DATA_DIRS : "$GSETTINGS_SCHEMAS_PATH"
  '';

  doCheck = true;

  meta = with stdenv.lib; {
    description = "Utility used in the GNOME desktop environment for screenshots";
    homepage = http://en.wikipedia.org/wiki/GNOME_Screenshot;
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

{ stdenv
, fetchurl
, gettext
, intltool
, itstool
, makeWrapper

, adwaita-icon-theme
, cairo
, gdk-pixbuf
, glib
, gtk3
, libnotify
, libxml2
, libxslt
, pango
, webkitgtk
, xorg
}:

stdenv.mkDerivation rec {
  name = "zenity-${version}";
  versionMajor = "3.18";
  versionMinor = "1.1";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/zenity/${versionMajor}/${name}.tar.xz";
    sha256 = "02m88dfm1rziqk2ywakwib06wl1rxangbzih6cp8wllbyl1plcg6";
  };

  nativeBuildInputs = [
    gettext
    intltool
    itstool
    makeWrapper
  ];

  buildInputs = [
    adwaita-icon-theme
    gdk-pixbuf
    glib
    gtk3
    libnotify
    libxml2
    #webkitgtk
    xorg.libX11
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--enable-libnotify"
    #"--enable-webkitgtk"
    "--disable-debug"
    "--enable-compile-warnings"
    "--disable-iso-c"
    "--enable-nls"
    "--enable-rpath"
  ];

  preFixup = ''
    wrapProgram $out/bin/zenity \
      --set 'GDK_PIXBUF_MODULE_FILE' "$GDK_PIXBUF_MODULE_FILE" \
      --prefix 'XDG_DATA_DIRS' : "$XDG_ICON_DIRS"
  '';

  meta = with stdenv.lib; {
    description = "Creates simple interactive graphical dialogs";
    homepage = https://help.gnome.org/users/zenity/;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}

{ stdenv
#, autoreconfHook
, fetchurl
, gettext
#, gnome-common
, intltool
, itstool
, makeWrapper
#, yelp-tools

, adwaita-icon-theme
, at-spi2-core
, gdk-pixbuf
, glib
, gtk3
, libnotify
, libxml2
, webkitgtk
, xorg
}:

let
  inherit (stdenv.lib)
    enFlag
    optionals;
in

stdenv.mkDerivation rec {
  name = "zenity-${version}";
  versionMajor = "3.20";
  versionMinor = "0";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/zenity/${versionMajor}/${name}.tar.xz";
    sha256 = "02e8759397f813c0a620b93ebeacdab9956191c9dc0d0fcba1815c5ea3f15a48";
  };

  nativeBuildInputs = [
    #autoreconfHook
    gettext
    #gnome-common
    intltool
    itstool
    makeWrapper
    #yelp-tools
  ];

  buildInputs = [
    adwaita-icon-theme
    gdk-pixbuf
    glib
    gtk3
    libnotify
    libxml2
    webkitgtk
  ] ++ optionals gtk3.x11_backend [
    xorg.libX11
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    (enFlag "libnotify" (libnotify != null) null)
    (enFlag "webkitgtk" (webkitgtk != null) null)
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
      x86_64-linux;
  };
}

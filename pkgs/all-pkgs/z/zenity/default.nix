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
, gtk
, libnotify
, libxml2
, webkitgtk
, xorg

, channel
}:

let
  inherit (stdenv.lib)
    boolEn
    optionals;

  source = (import ./sources.nix { })."${channel}";
in
stdenv.mkDerivation rec {
  name = "zenity-${source.version}";

  src = fetchurl {
    url = "mirror://gnome/sources/zenity/${channel}/${name}.tar.xz";
    hashOutput = false;
    inherit (source) sha256;
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
    gtk
    libnotify
    libxml2
    webkitgtk
  ] ++ optionals gtk.x11_backend [
    xorg.libX11
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--${boolEn (libnotify != null)}-libnotify"
    "--${boolEn (webkitgtk != null)}-webkitgtk"
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

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      sha256Url = "https://download.gnome.org/sources/zenity/${channel}/"
        + "${name}.sha256sum";
      failEarly = true;
    };
  };

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

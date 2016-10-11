{ stdenv
, autoconf-archive
, fetchurl
, gettext
, intltool
, lib
, makeWrapper

, adwaita-icon-theme
, appstream-glib
, curl
, dconf
, gdk-pixbuf
, geoip
, glib
, gtk_3
, json-glib
, libnotify
, libproxy
}:

let
  inherit (lib)
    boolWt;

  version = "1.3.1";
in
stdenv.mkDerivation rec {
  name = "transmission-remote-gtk-${version}";

  src = fetchurl {
    url = "https://github.com/transmission-remote-gtk/"
      + "transmission-remote-gtk/releases/download/${version}/${name}.tar.xz";
    hashOutput = false;
    sha256 = "1b29c573b1e205e3e7c2433dc4a48f9574278d97e033845d19bbffa1d7f75345";
  };

  nativeBuildInputs = [
    autoconf-archive
    gettext
    intltool
    makeWrapper
  ];

  buildInputs = [
    adwaita-icon-theme
    appstream-glib
    curl
    dconf
    gdk-pixbuf
    geoip
    glib
    gtk_3
    json-glib
    libnotify
    libproxy
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--disable-debug"
    "--enable-nls"
    "--disable-desktop-validate"
    "--disable-desktop-database-update"
    "--disable-appstream-util"
    "--${boolWt (geoip != null)}-libgeoip"
    "--${boolWt (libnotify != null)}-libnotify"
    "--without-libmrss"
    "--${boolWt (libproxy != null)}-libproxy"
    "--without-libappindicator"
  ];

  preFixup = ''
    wrapProgram $out/bin/transmission-remote-gtk \
      --set 'GDK_PIXBUF_MODULE_FILE' "$GDK_PIXBUF_MODULE_FILE" \
      --prefix 'GIO_EXTRA_MODULES' : "$GIO_EXTRA_MODULES" \
      --prefix 'XDG_DATA_DIRS' : "$GSETTINGS_SCHEMAS_PATH" \
      --prefix 'XDG_DATA_DIRS' : "$out/share" \
      --prefix 'XDG_DATA_DIRS' : "$XDG_ICON_DIRS"
  '';

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      pgpsigUrls = map (n: "${n}.asc") src.urls;
      pgpKeyFingerprint = "108B F221 2A05 1F4A 72B1  8448 B3C7 CE21 0DE7 6DFC";
      failEarly = true;
    };
};

  meta = with lib; {
    description = "A GTK remote interface to the Transmission BitTorrent client";
    homepage = https://github.com/transmission-remote-gtk/transmission-remote-gtk;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

{ stdenv
, fetchurl
, gettext
, intltool
, makeWrapper

, dconf
, gcr
, glib
, gobject-introspection
, gtk3
, json-glib
, kerberos
, libsecret
, libsoup
, libxml2
, pango
, rest
, telepathy_glib
, vala
, webkitgtk
, xorg
}:

let
  inherit (stdenv.lib)
    enFlag;
in
stdenv.mkDerivation rec {
  name = "gnome-online-accounts-${version}";
  versionMajor = "3.22";
  versionMinor = "1";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/gnome-online-accounts/${versionMajor}/"
      + "${name}.tar.xz";
    sha256Url = "mirror://gnome/sources/gnome-online-accounts/"
      + "${versionMajor}/${name}.sha256sum";
    sha256 = "83c2b707c0a7908c6fe93db1c415fa45bffb2b1d9fb4648badc749ce69cda50e";
  };

  nativeBuildInputs = [
    gettext
    intltool
    makeWrapper
  ];

  buildInputs = [
    dconf
    gcr
    glib
    gobject-introspection
    gtk3
    json-glib
    kerberos
    libsecret
    libsoup
    libxml2
    rest
    pango
    telepathy_glib
    vala
    webkitgtk
    xorg.libX11
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--disable-debug"
    "--enable-schemas-compile"
    "--enable-compile-warnings"
    "--disable-iso-c"
    "--disable-documentation"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    (enFlag "introspection" (gobject-introspection != null) null)
    (enFlag "vala" (vala != null) null)
    (enFlag "telepathy" (telepathy_glib != null) null)
    "--enable-backend"
    "--disable-inspector"
    "--enable-exchange"
    "--enable-flickr"
    "--enable-foursquare"
    "--enable-google"
    "--enable-imap-smtp"
    "--enable-media-server"
    "--enable-owncloud"
    "--enable-facebook"
    "--enable-windows-live"
    "--enable-pocket"
    "--enable-kerberos"
    "--enable-lastfm"
    "--enable-nls"
  ];

  preFixup = ''
    wrapProgram $out/libexec/goa-daemon \
      --set 'GSETTINGS_BACKEND' 'dconf' \
      --prefix 'GIO_EXTRA_MODULES' : "$GIO_EXTRA_MODULES" \
      --prefix 'XDG_DATA_DIRS' : "$GSETTINGS_SCHEMAS_PATH" \
      --prefix 'XDG_DATA_DIRS' : "$out/share"
  '';

  meta = with stdenv.lib; {
    description = "GNOME framework for accessing online accounts";
    homepage = https://wiki.gnome.org/Projects/GnomeOnlineAccounts;
    license = licenses.lgpl2Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

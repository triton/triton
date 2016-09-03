{ stdenv
, fetchurl
, intltool
, makeWrapper

, adwaita-icon-theme
, atk
, dbus-glib
, dconf
, gconf
, gdk-pixbuf
, glib
, glib-networking
, gnome-keyring
, gobject-introspection
, gsettings-desktop-schemas
, gtk3
, hicolor-icon-theme
, iso-codes
, jansson
#, libglade
, libgnome-keyring
, libgudev
, libnotify
, libsecret
, mobile_broadband_provider_info
, modemmanager
, networkmanager
, pango
, polkit
, systemd_lib
}:

let
  inherit (stdenv.lib)
    enFlag
    wtFlag;
in
stdenv.mkDerivation rec {
  name = "network-manager-applet-${version}";
  versionMajor = "1.4";
  versionMinor = "0";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/network-manager-applet/${versionMajor}/"
      + "${name}.tar.xz";
    sha256Url = "mirror://gnome/sources/network-manager-applet/${versionMajor}/"
      + "${name}.sha256sum";
    sha256 = "d9f5f1e151b8edbbcebb6f818eed9a49b53aadcb4e8aed2cae4fc09996278331";
  };

  propagatedUserEnvPkgs = [
    gconf
    gnome-keyring
    hicolor-icon-theme
  ];

  nativeBuildInputs = [
    intltool
    makeWrapper
  ];

  buildInputs = [
    adwaita-icon-theme
    atk
    dbus-glib
    dconf
    gdk-pixbuf
    gconf
    glib
    libgnome-keyring
    gobject-introspection
    gsettings-desktop-schemas
    gtk3
    hicolor-icon-theme
    iso-codes
    jansson
    #libglade
    libgudev
    libnotify
    libsecret
    modemmanager
    networkmanager
    pango
    polkit
    systemd_lib
  ];

  configureFlags = [
    "--sysconfdir=/etc"
    "--disable-maintainer-mode"
    "--enable-nls"
    (enFlag "iso-codes" (iso-codes != null) null)
    "--disable-migration"
    (enFlag "introspection" (gobject-introspection != null) null)
    "--enable-schemas-compile"
    "--enable-more-warnings"
    #"--with-appindicator"
    (wtFlag "wwan" (modemmanager != null) null)
  ];

  makeFlags = [
    ''CFLAGS=-DMOBILE_BROADBAND_PROVIDER_INFO=\"${mobile_broadband_provider_info}/share/mobile-broadband-provider-info/serviceproviders.xml\"''
  ];

  preInstall = ''
    installFlagsArray+=("sysconfdir=$out/etc")
  '';

  preFixup = ''
    wrapProgram "$out/bin/nm-applet" \
      --set 'GDK_PIXBUF_MODULE_FILE' "$GDK_PIXBUF_MODULE_FILE" \
      --set 'GSETTINGS_BACKEND' 'dconf' \
      --prefix 'GIO_EXTRA_MODULES' : "$GIO_EXTRA_MODULES" \
      --prefix XDG_DATA_DIRS : "${gtk3}/share" \
      --prefix XDG_DATA_DIRS : "$GSETTINGS_SCHEMAS_PATH" \
      --prefix XDG_DATA_DIRS : "$XDG_ICON_DIRS" \
      --prefix XDG_DATA_DIRS : "$out/share"

    wrapProgram "$out/bin/nm-connection-editor" \
      --set 'GDK_PIXBUF_MODULE_FILE' "$GDK_PIXBUF_MODULE_FILE" \
      --set 'GSETTINGS_BACKEND' 'dconf' \
      --prefix 'GIO_EXTRA_MODULES' : "$GIO_EXTRA_MODULES" \
      --prefix XDG_DATA_DIRS : "${gtk3}/share" \
      --prefix XDG_DATA_DIRS : "$GSETTINGS_SCHEMAS_PATH" \
      --prefix XDG_DATA_DIRS : "$XDG_ICON_DIRS" \
      --prefix XDG_DATA_DIRS : "$out/share"
  '';

  meta = with stdenv.lib; {
    description = "NetworkManager control applet";
    homepage = http://projects.gnome.org/NetworkManager/;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

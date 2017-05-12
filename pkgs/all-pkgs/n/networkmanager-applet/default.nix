{ stdenv
, fetchurl
, intltool
, lib
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
, gtk_3
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

, channel
}:

let
  inherit (lib)
    boolEn
    boolWt;

  source = (import ./sources.nix { })."${channel}";
in
stdenv.mkDerivation rec {
  name = "network-manager-applet-${source.version}";

  src = fetchurl {
    url = "mirror://gnome/sources/network-manager-applet/${channel}/"
      + "${name}.tar.xz";
    hashOutput = false;
    inherit (source) sha256;
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
    gtk_3
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
    "--${boolEn (iso-codes != null)}-iso-codes"
    "--${boolEn (gobject-introspection != null)}-introspection"
    "--enable-schemas-compile"
    "--enable-more-warnings"
    #"--enable-lto"
    #"--enable-ld-gc"
    #"--with-appindicator"
    "--${boolWt (modemmanager != null)}-wwan"
    /**/"--without-selinux"
    #"--${boolWt (libselinux != null)}-selinux"
    #"--with-team"
    #"--with-gcr"
    "--with-more-asserts=0"
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
      --prefix XDG_DATA_DIRS : "${gtk_3}/share" \
      --prefix XDG_DATA_DIRS : "$GSETTINGS_SCHEMAS_PATH" \
      --prefix XDG_DATA_DIRS : "$XDG_ICON_DIRS" \
      --prefix XDG_DATA_DIRS : "$out/share"

    wrapProgram "$out/bin/nm-connection-editor" \
      --set 'GDK_PIXBUF_MODULE_FILE' "$GDK_PIXBUF_MODULE_FILE" \
      --set 'GSETTINGS_BACKEND' 'dconf' \
      --prefix 'GIO_EXTRA_MODULES' : "$GIO_EXTRA_MODULES" \
      --prefix XDG_DATA_DIRS : "${gtk_3}/share" \
      --prefix XDG_DATA_DIRS : "$GSETTINGS_SCHEMAS_PATH" \
      --prefix XDG_DATA_DIRS : "$XDG_ICON_DIRS" \
      --prefix XDG_DATA_DIRS : "$out/share"
  '';

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      sha256Url = "https://download.gnome.org/sources/network-manager-applet/"
        + "${channel}/${name}.sha256sum";
      failEarly = true;
    };
  };

  meta = with lib; {
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

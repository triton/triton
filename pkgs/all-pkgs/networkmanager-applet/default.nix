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
, glib-networking
, gnome-keyring
, gobject-introspection
, gsettings-desktop-schemas
, gtk3
, hicolor_icon_theme
, isocodes
#, libglade
, libgnome-keyring
, libgudev
, libnotify
, libsecret
, mobile_broadband_provider_info
, networkmanager
, pango
, polkit
, systemd_lib
}:

with {
  inherit (stdenv.lib)
    enFlag;
};

stdenv.mkDerivation rec {
  name = "network-manager-applet-${version}";
  versionMajor = "1.0";
  versionMinor = "10";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/network-manager-applet/${versionMajor}/" +
          "${name}.tar.xz";
    sha256 = "1szh5jyijxm6z55irkp5s44pwah0nikss40mx7pvpk38m8zaqidh";
  };

  propagatedUserEnvPkgs = [
    gconf
    gnome-keyring
    hicolor_icon_theme
  ];

  nativeBuildInputs = [
    intltool
    makeWrapper
  ];

  buildInputs = [
    adwaita-icon-theme
    atk
    dbus-glib
    gdk-pixbuf
    gconf
    libgnome-keyring
    gobject-introspection
    gsettings-desktop-schemas
    gtk3
    hicolor_icon_theme
    isocodes
    #libglade
    libgudev
    libnotify
    libsecret
    networkmanager
    pango
    polkit
    systemd_lib
  ];

  configureFlags = [
    "--sysconfdir=/etc"
    "--disable-maintainer-mode"
    "--enable-nls"
    "--enable-iso-codes"
    "--disable-migration"
    "--enable-introspection"
    (enFlag "introspection" (gobject-introspection != null) null)
    "--enable-schemas-compile"
    "--enable-more-warnings"
    "--with-bluetooth"
    "--without-modem-manager-1"
  ];

  makeFlags = [
    ''CFLAGS=-DMOBILE_BROADBAND_PROVIDER_INFO=\"${mobile_broadband_provider_info}/share/mobile-broadband-provider-info/serviceproviders.xml\"''
  ];

  preInstall = ''
    installFlagsArray+=( "sysconfdir=$out/etc" )
  '';

  preFixup = ''
    wrapProgram "$out/bin/nm-applet" \
      --set 'GDK_PIXBUF_MODULE_FILE' "$GDK_PIXBUF_MODULE_FILE" \
      --prefix GIO_EXTRA_MODULES : "${glib-networking}/lib/gio/modules" \
      --prefix GIO_EXTRA_MODULES : "${dconf}/lib/gio/modules" \
      --prefix XDG_DATA_DIRS : "${gtk3}/share" \
      --prefix XDG_DATA_DIRS : "$out/share" \
      --prefix XDG_DATA_DIRS : "$GSETTINGS_SCHEMAS_PATH" \
      --prefix XDG_DATA_DIRS : "$XDG_ICON_DIRS" \
      --set GCONF_CONFIG_SOURCE "xml::~/.gconf" \
      --prefix PATH ":" "${gconf}/bin"
    wrapProgram "$out/bin/nm-connection-editor" \
      --set 'GDK_PIXBUF_MODULE_FILE' "$GDK_PIXBUF_MODULE_FILE" \
      --prefix XDG_DATA_DIRS : "${gtk3}/share" \
      --prefix XDG_DATA_DIRS : "$out/share" \
      --prefix XDG_DATA_DIRS : "$GSETTINGS_SCHEMAS_PATH" \
      --prefix XDG_DATA_DIRS : "$XDG_ICON_DIRS"
  '';

  meta = with stdenv.lib; {
    description = "NetworkManager control applet";
    homepage = http://projects.gnome.org/NetworkManager/;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}

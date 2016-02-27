{ stdenv
, fetchTritonPatch
, fetchurl
, intltool
, makeWrapper

, accountsservice
, adwaita-icon-theme
, clutter
, clutter-gtk
, colord
, colord-gtk
, cracklib
, cups
, dconf
, docbook_xsl
, docbook_xsl_ns
, fontconfig
, gdk-pixbuf
, glib
, gnome-bluetooth
, gnome-desktop
, gnome-menus
, gnome-online-accounts
, gnome-settings-daemon
, gnome-themes-standard
, grilo
, gsettings-desktop-schemas
, gtk3
, ibus
, icu
, krb5_lib
, libcanberra
, libgnomekbd
, libgtop
, libgudev
, libnotify
, libpwquality
, librsvg
, libsoup
, libtool
, libwacom
, libxml2
, libxslt
, mesa_noglu
, modemmanager
, networkmanager
, networkmanager-applet
, polkit
, pulseaudio_lib
, python
, samba
, shared_mime_info
, sound-theme-freedesktop
, systemd_lib
, tzdata
, upower
, vino
, xorg
}:

with {
  inherit (stdenv.lib)
    enFlag;
};

stdenv.mkDerivation rec {
  name = "gnome-control-center-${version}";
  versionMajor = "3.18";
  versionMinor = "2";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/gnome-control-center/${versionMajor}/${name}.tar.xz";
    sha256 = "1bgqg1sl3cp2azrwrjgwx3jzk9n3w76xpcyvk257qavx4ibn3zin";
  };

  propagatedUserEnvPkgs = [
    gnome-themes-standard
    libgnomekbd
  ];

  nativeBuildInputs = [
    intltool
    makeWrapper
  ];

  buildInputs = [
    accountsservice
    adwaita-icon-theme
    clutter
    clutter-gtk
    colord
    colord-gtk
    cups
    dconf
    docbook_xsl
    docbook_xsl_ns
    fontconfig
    gdk-pixbuf
    glib
    gnome-bluetooth
    gnome-desktop
    gnome-menus
    gnome-online-accounts
    gnome-settings-daemon
    grilo
    gsettings-desktop-schemas
    gtk3
    ibus
    icu
    krb5_lib
    libcanberra
    libgtop
    libgudev
    libnotify
    libpwquality
    librsvg
    libsoup
    libtool
    libwacom
    libxml2
    libxslt
    mesa_noglu
    modemmanager
    networkmanager
    networkmanager-applet
    polkit
    pulseaudio_lib
    samba
    shared_mime_info
    systemd_lib
    upower
    vino
    xorg.libSM
    xorg.libX11
    xorg.libXi
    xorg.libxkbfile
  ];

  patches = [
    (fetchTritonPatch {
      rev = "453aedffa95d1c459a15a6f1fb8cb9d0ce810803";
      file = "gnome-control-center/vpn_plugins_path.patch";
      sha256 = "1e855649929c56466995ed5ace80cbd56617c8855b7d22b4f352c06752c3e126";
    })
  ];

  postPatch =
  /* Patch path to gnome version file */ ''
    sed -i panels/info/cc-info-panel.c \
      -e 's|DATADIR "/gnome/gnome-version.xml"|"${gnome-desktop}/share/gnome/gnome-version.xml"|'
  '';

  configureFlags = [
    "--disable-maintainer-mode"
    "--disable-debug"
    "--enable-compile-warnings"
    "--enable-nls"
    "--disable-documentation"
    (enFlag "ibus" (ibus != null) null)
    (enFlag "cups" (cups != null) null)
    "--disable-update-mimedb"
    "--disable-more-warnings"
    "--with-x"
    "--without-cheese"
  ];

  preBuild = ''
    substituteInPlace tz.h \
      --replace "/usr/share/zoneinfo/zone.tab" "${tzdata}/share/zoneinfo/zone.tab"
    substituteInPlace panels/datetime/tz.h \
      --replace "/usr/share/zoneinfo/zone.tab" "${tzdata}/share/zoneinfo/zone.tab"

    # hack to make test-endianess happy
    mkdir -p $out/share/locale
    substituteInPlace panels/datetime/test-endianess.c \
      --replace "/usr/share/locale/" "$out/share/locale/"
  '';

  preFixup = ''
    for i in $out/share/applications/* ; do
      substituteInPlace $i \
        --replace "gnome-control-center" "$out/bin/gnome-control-center"
    done
  '' + ''
    wrapProgram $out/bin/gnome-control-center \
      --set 'GDK_PIXBUF_MODULE_FILE' "$GDK_PIXBUF_MODULE_FILE" \
      --set 'GSETTINGS_BACKEND' 'dconf' \
      --prefix 'GIO_EXTRA_MODULES' : "$GIO_EXTRA_MODULES" \
      --prefix 'XDG_DATA_DIRS' : "$GSETTINGS_SCHEMAS_PATH" \
      --prefix 'XDG_DATA_DIRS' : "$out/share" \
      --prefix 'XDG_DATA_DIRS' : "$XDG_ICON_DIRS"
  '';

  meta = with stdenv.lib; {
    description = "Utilities to configure the GNOME desktop";
    homepage = https://git.gnome.org/browse/gnome-control-center/;
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };

}

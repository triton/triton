{ stdenv
, fetchTritonPatch
, fetchurl
, intltool
, makeWrapper

, adwaita-icon-theme
, dconf
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
, libgnomekbd
, upower
, vino

, libcanberra
, accountsservice
, libpwquality
, libpulseaudio
, gdk-pixbuf
, librsvg
, libnotify
, libxml2
, polkit
, libxslt
, libgtop
, libsoup
, colord
, colord-gtk
, cracklib
, python
, libkrb5
, networkmanager-applet
, networkmanager
, libwacom
, samba
, shared_mime_info
, tzdata
, icu
, libtool
, udev
, libgudev
, docbook_xsl
, docbook_xsl_ns
, modemmanager
, clutter
, fontconfig
, sound-theme-freedesktop
, cups
, clutter-gtk
, mesa_noglu
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
    adwaita-icon-theme
    ibus
    gtk3
    glib
    upower
    libcanberra
    gsettings-desktop-schemas
    libxml2
    gnome-desktop
    gnome-settings-daemon
    polkit
    libxslt
    libgtop
    gnome-menus
    gnome-online-accounts
    libsoup
    colord
    libpulseaudio
    fontconfig
    colord-gtk
    libpwquality
    accountsservice
    libkrb5
    networkmanager-applet
    libwacom
    samba
    libnotify
    shared_mime_info
    icu
    libtool
    docbook_xsl
    docbook_xsl_ns
    grilo
    gdk-pixbuf
    librsvg
    clutter
    vino
    udev
    libgudev
    networkmanager
    modemmanager
    gnome-bluetooth
    cups
    clutter-gtk
    mesa_noglu
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
      --prefix 'GIO_EXTRA_MODULES' : "${dconf}/lib/gio/modules" \
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
    platforms = [
      "x86_64-linux"
    ];
  };

}

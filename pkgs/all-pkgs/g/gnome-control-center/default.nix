{ stdenv
, autoreconfHook
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
, docbook-xsl
, docbook-xsl-ns
, fontconfig
, gdk-pixbuf
, glib
, gnome-bluetooth
, gnome-common
, gnome-desktop
, gnome-menus
#, gnome-online-accounts
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
, samba_client
, shared-mime-info
, sound-theme-freedesktop
, systemd_lib
, tzdata
, upower
, vino
, xorg
}:

let
  inherit (stdenv.lib)
    enFlag
    optionalString;
in
stdenv.mkDerivation rec {
  name = "gnome-control-center-${version}";
  versionMajor = "3.20";
  versionMinor = "1";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/gnome-control-center/${versionMajor}/${name}.tar.xz";
    sha256Url = "mirror://gnome/sources/gnome-control-center/${versionMajor}/${name}.sha256sum";
    sha256 = "ce6474fc60f78ed3cfaf555e55a52ec3ebb6437fa184e08ad6077bbec380a1ed";
  };

  nativeBuildInputs = [
    autoreconfHook
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
    docbook-xsl
    docbook-xsl-ns
    fontconfig
    gdk-pixbuf
    glib
    gnome-bluetooth
    gnome-common
    gnome-desktop
    gnome-menus
    #gnome-online-accounts
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
    samba_client
    shared-mime-info
    systemd_lib
    upower
    vino
    xorg.libSM
    xorg.libX11
    xorg.libXi
    xorg.libxkbfile
  ];

  propagatedUserEnvPkgs = [
    gnome-themes-standard
    libgnomekbd
  ];

  postUnpack = ''
    rm -v $srcRoot/configure
  '';

  patches = [
    (fetchTritonPatch {
      rev = "453aedffa95d1c459a15a6f1fb8cb9d0ce810803";
      file = "gnome-control-center/vpn_plugins_path.patch";
      sha256 = "1e855649929c56466995ed5ace80cbd56617c8855b7d22b4f352c06752c3e126";
    })
    # Patch from Gentoo for making various features optional
    (fetchTritonPatch {
      rev = "a59629461bca11af9c83259900cae13628f79d79";
      file = "gnome-control-center/gnome-control-center-3.20.0-goa-optional.patch";
      sha256 = "b43d9ed2ca08159b9d1629ec0c28ac3853b6d6929a85446840696ef5d37b1eb7";
    })
  ];

  postPatch =
    /* Patch path to gnome version file */ ''
      sed -i panels/info/cc-info-panel.c \
        -e 's|DATADIR "/gnome/gnome-version.xml"|"${gnome-desktop}/share/gnome/gnome-version.xml"|'
    '' + #optionalString (gnome-online-accounts == null)
    /* Remove unconditional check for gnome-online-accounts */ ''
      sed -i configure.ac \
        -e '/goa-1.0 >=/d'
    '';

  configureFlags = [
    "--disable-maintainer-mode"
    "--disable-debug"
    "--enable-nls"
    "--disable-documentation"
    (enFlag "ibus" (ibus != null) null)
    # Remove dependency on webkit
    #(enFlag "goa" (gnome-online-accounts != null) null)
    "--disable-goa"
    "--enable-color"
    "--enable-bluetooth"
    (enFlag "cups" (cups != null) null)
    "--enable-wacom"
    "--enable-kerberos"
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

    wrapProgram $out/libexec/gnome-control-center-search-provider \
      --prefix 'XDG_DATA_DIRS' : "$out/share"
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

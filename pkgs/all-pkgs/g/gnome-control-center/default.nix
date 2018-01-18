{ stdenv
, autoreconfHook
, fetchTritonPatch
, fetchurl
, intltool
, lib
, makeWrapper

, accountsservice
, adwaita-icon-theme
, at-spi2-core
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
, libsm
, libsoup
, libtool
, libwacom
, libx11
, libxi
, libxkbfile
, libxml2
, libxslt
, modemmanager
, networkmanager
, networkmanager-applet
, opengl-dummy
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

, channel ? "3.26"
}:

let
  inherit (lib)
    boolEn
    optionalString;

  sources = {
    "3.26" = {
      version = "3.26.2";
      sha256 = "07aed27d6317f2cad137daa6d94a37ad02c32b958dcd30c8f07d0319abfb04c5";
    };
  };
  source = sources."${channel}";
in
stdenv.mkDerivation rec {
  name = "gnome-control-center-${source.version}";

  src = fetchurl {
    url = "mirror://gnome/sources/gnome-control-center/${channel}/${name}.tar.xz";
    hashOutput = false;
    inherit (source) sha256;
  };

  nativeBuildInputs = [
    autoreconfHook
    intltool
    makeWrapper
  ];

  buildInputs = [
    accountsservice
    adwaita-icon-theme
    at-spi2-core
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
    libsm
    libsoup
    libtool
    libwacom
    libx11
    libxi
    libxkbfile
    libxml2
    libxslt
    modemmanager
    networkmanager
    networkmanager-applet
    opengl-dummy
    polkit
    pulseaudio_lib
    samba_client
    shared-mime-info
    systemd_lib
    upower
    vino
  ];

  propagatedUserEnvPkgs = [
    gnome-themes-standard
    libgnomekbd
  ];

  postUnpack = ''
    rm -v $srcRoot/configure
  '';

  patches = [
    # (fetchTritonPatch {
    #   rev = "453aedffa95d1c459a15a6f1fb8cb9d0ce810803";
    #   file = "gnome-control-center/vpn_plugins_path.patch";
    #   sha256 = "1e855649929c56466995ed5ace80cbd56617c8855b7d22b4f352c06752c3e126";
    # })
    # Patch from Gentoo for making various features optional
    (fetchTritonPatch {
      rev = "09b054709e85652d09ea4856f03ef345c7181734";
      file = "g/gnome-control-center/gnome-control-center-3.23.90-optional.patch";
      sha256 = "918f160c2d69e82bf81920d4fb77244837b80dafdb00509f570a14090657de36";
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
    '' + /* Fix hardcoded paths */ ''
      sed -i panels/datetime/tz.h \
        -e 's,/usr/share/zoneinfo/zone.tab,${tzdata}/share/zoneinfo/zone.tab,g'
      sed -i panels/printers/pp-options-dialog.c \
        -i panels/printers/pp-host.c \
        -e 's,/usr,${cups},g'
      # FIXME: assumes this will only be run on a Nix-based system
      # IMPURE
      sed -i panels/user-accounts/run-passwd.c \
        -e 's,/usr/bin/passwd,/var/setuid-wrappers/passwd,'
    '';

  configureFlags = [
    "--disable-maintainer-mode"
    "--disable-debug"
    "--enable-nls"
    "--disable-documentation"
    "--${boolEn (ibus != null)}-ibus"
    # Remove dependency on webkit
    #"--${boolEn (gnome-online-accounts != null)}-goa"
    "--disable-goa"
    "--enable-color"
    "--enable-bluetooth"
    "--${boolEn (cups != null)}-cups"
    "--enable-wacom"
    "--enable-kerberos"
    "--disable-update-mimedb"
    "--disable-more-warnings"
    "--with-x"
    "--without-cheese"
  ];

  preFixup = ''
    for i in $out/share/applications/* ; do
      sed -i $i \
        -e "s,gnome-control-center,$out/bin/gnome-control-center,g"
    done
  '' + ''
    wrapProgram $out/bin/gnome-control-center \
      --set 'GDK_PIXBUF_MODULE_FILE' "${gdk-pixbuf.loaders.cache}" \
      --set 'GSETTINGS_BACKEND' 'dconf' \
      --prefix 'GIO_EXTRA_MODULES' : "$GIO_EXTRA_MODULES" \
      --prefix 'XDG_DATA_DIRS' : "$GSETTINGS_SCHEMAS_PATH" \
      --prefix 'XDG_DATA_DIRS' : "$out/share" \
      --prefix 'XDG_DATA_DIRS' : "${shared-mime-info}/share" \
      --prefix 'XDG_DATA_DIRS' : "$XDG_ICON_DIRS"

    wrapProgram $out/libexec/gnome-control-center-search-provider \
      --prefix 'XDG_DATA_DIRS' : "$out/share"
  '';

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      sha256Url = "https://download.gnome.org/sources/gnome-control-center/"
        + "${channel}/${name}.sha256sum";
      failEarly = true;
    };
  };

  meta = with lib; {
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

{ stdenv
, docbook-xsl
, docbook-xsl-ns
, fetchurl
, gettext
, intltool
, lib
, libtool
, libxslt
, makeWrapper

, adwaita-icon-theme
, alsa-lib
, cairo
, colord
, cups
, dconf
, fontconfig
, gconf
, gdk-pixbuf
, geoclue
, geocode-glib
, glib
, gnome-desktop
, gnome-themes-standard
, gsettings-desktop-schemas
, gtk
, ibus
, inputproto
, lcms2
, libcanberra
, libgudev
, libgweather
, libnotify
, librsvg
, libwacom
, libxml2
, networkmanager
, nss
, pango
, polkit
, pulseaudio_lib
, systemd_lib
, upower
, wayland
, xf86-input-wacom
, xorg

, channel
}:

let
  inherit (lib)
    boolEn
    boolWt;

  source = (import ./sources.nix { })."${channel}";
in
stdenv.mkDerivation rec {
  name = "gnome-settings-daemon-${source.version}";

  src = fetchurl {
    url = "mirror://gnome/sources/gnome-settings-daemon/${channel}/"
      + "${name}.tar.xz";
    hashOutput = false;
    inherit (source) sha256;
  };

  nativeBuildInputs = [
    docbook-xsl
    docbook-xsl-ns
    gettext
    intltool
    libtool
    libxslt
    makeWrapper
  ];

  buildInputs = [
    adwaita-icon-theme
    alsa-lib
    cairo
    colord
    cups
    dconf
    fontconfig
    gconf
    geoclue
    geocode-glib
    gdk-pixbuf
    glib
    gnome-desktop
    gnome-themes-standard
    gsettings-desktop-schemas
    gtk
    #ibus
    inputproto
    lcms2
    libcanberra
    libgudev
    libgweather
    libnotify
    librsvg
    libwacom
    libxml2
    networkmanager
    nss
    pango
    polkit
    pulseaudio_lib
    systemd_lib
    upower
    wayland
    xf86-input-wacom
    xorg.libX11
    xorg.libXext
    xorg.libXi
    xorg.libXfixes
    xorg.libxkbfile
    xorg.libXtst
    xorg.libXxf86misc
    xorg.xf86miscproto
    xorg.xkeyboardconfig
    xorg.xproto
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--enable-nls"
    "--enable-compile-warnings"
    "--disable-iso-c"
    "--enable-schemas-compile"
    "--${boolEn (libgudev != null)}-gudev"
    "--${boolEn (alsa-lib != null)}-alsa"
    "--${boolEn (wayland != null)}-wayland"
    "--${boolEn (nss != null)}-smartcard-support"
    "--${boolEn (cups != null)}-cups"
    "--enable-rfkill"
    "--${boolEn (networkmanager != null)}-network-manager"
    "--disable-profiling"
    "--${boolEn (libxslt != null)}-man"
    "--disable-more-warnings"
    "--disable-debug"
    "--${boolWt (nss != null)}-nssdb"
  ];

  preFixup = ''
    wrapProgram $out/libexec/gnome-settings-daemon \
      --set 'GDK_PIXBUF_MODULE_FILE' "$GDK_PIXBUF_MODULE_FILE" \
      --set 'GSETTINGS_BACKEND' 'dconf' \
      --prefix 'GIO_EXTRA_MODULES' : "$GIO_EXTRA_MODULES" \
      --prefix 'XDG_DATA_DIRS' : "$GSETTINGS_SCHEMAS_PATH" \
      --prefix 'XDG_DATA_DIRS' : "$out/share" \
      --prefix 'XDG_DATA_DIRS' : "$XDG_ICON_DIRS"

    wrapProgram $out/libexec/gsd-list-wacom \
      --set 'GSETTINGS_BACKEND' 'dconf' \
      --prefix 'GIO_EXTRA_MODULES' : "$GIO_EXTRA_MODULES" \
      --prefix 'XDG_DATA_DIRS' : "$GSETTINGS_SCHEMAS_PATH" \
      --prefix 'XDG_DATA_DIRS' : "$out/share"
  '';

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      sha256Url = "https://download.gnome.org/sources/"
        + "gnome-settings-daemon/${channel}/${name}.sha256sum";
      failEarly = true;
    };
  };

  meta = with lib; {
    description = "Gnome Settings Daemon";
    homepage = https://git.gnome.org/browse/gnome-settings-daemon;
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

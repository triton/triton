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
, lcms2
, libcanberra
, libgudev
, libgweather
, libnotify
, librsvg
, libwacom
, libx11
, libxext
, libxfixes
, libxi
, libxkbfile
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
#, xkeyboardconfig
, xorg
, xorgproto

, channel
}:

# NOTE: Runtime dependency on mutter & gnome-session.
# FIXME: re-verify actual dependencies.

let
  inherit (lib)
    boolEn
    boolWt;

  sources = {
    "3.26" = {
      version = "3.26.2";
      sha256 = "5a3d156b35e03fa3c28fddd0321f6726082a711973dee2af686370faae2e75e4";
    };
  };
  source = sources."${channel}";
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
    lcms2
    libcanberra
    libgudev
    libgweather
    libnotify
    librsvg
    libwacom
    libx11
    libxext
    libxi
    libxfixes
    libxkbfile
    libxml2
    xorg.libXtst
    xorg.libXxf86misc
    networkmanager
    nss
    pango
    polkit
    pulseaudio_lib
    systemd_lib
    upower
    wayland
    xf86-input-wacom
    xorg.xkeyboardconfig
    xorgproto
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
    for prog in $out/libexec/*; do
      wrapProgram $prog \
        --set 'GSETTINGS_BACKEND' 'dconf' \
        --prefix 'GIO_EXTRA_MODULES' : "$GIO_EXTRA_MODULES" \
        --prefix 'XDG_DATA_DIRS' : "$GSETTINGS_SCHEMAS_PATH" \
        --prefix 'XDG_DATA_DIRS' : "$out/share"
    done
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

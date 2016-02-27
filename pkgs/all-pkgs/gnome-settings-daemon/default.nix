{ stdenv
, docbook_xsl
, docbook_xsl_ns
, fetchurl
, gettext
, intltool
, libtool
, libxslt
, makeWrapper

, adwaita-icon-theme
, cairo
, colord
, cups
, dconf
, fontconfig
, gconf
, gdk-pixbuf
, geoclue2
, geocode-glib
, glib
, gnome-desktop
, gnome-themes-standard
, gsettings-desktop-schemas
, gtk3
, ibus
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
, xf86_input_wacom
, xorg
}:

with {
  inherit (stdenv.lib)
    enFlag
    wtFlag;
};

stdenv.mkDerivation rec {
  name = "gnome-settings-daemon-${version}";
  versionMajor = "3.18";
  versionMinor = "2";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/gnome-settings-daemon/${versionMajor}/${name}.tar.xz";
    sha256 = "0vzwf875csyqx04fnra6zicmzcjc3s13bxxpcizlys12iwjwfw9h";
  };

  nativeBuildInputs = [
    docbook_xsl
    docbook_xsl_ns
    gettext
    intltool
    libtool
    libxslt
    makeWrapper
  ];

  buildInputs = [
    adwaita-icon-theme
    cairo
    colord
    cups
    dconf
    fontconfig
    gconf
    geoclue2
    geocode-glib
    gdk-pixbuf
    glib
    gnome-desktop
    gnome-themes-standard
    gsettings-desktop-schemas
    gtk3
    #ibus
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
    xf86_input_wacom
    xorg.inputproto
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
    (enFlag "gudev" (libgudev != null) null)
    (enFlag "wayland" (wayland != null) null)
    (enFlag "smartcard-support" (nss != null) null)
    (enFlag "cups" (cups != null) null)
    "--enable-rfkill"
    (enFlag "network-manager" (networkmanager != null) null)
    "--disable-profiling"
    (enFlag "man" (libxslt != null) null)
    "--disable-more-warnings"
    "--disable-debug"
    (wtFlag "nssdb" (nss != null) null)
  ];
      #"--prefix PATH : ${glib}/bin"

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

  meta = with stdenv.lib; {
    description = "Gnome Settings Daemon";
    homepage = https://git.gnome.org/browse/gnome-settings-daemon;
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}

{ stdenv
, docbook_xsl
, docbook_xsl_ns
, fetchurl
, intltool
, libtool
, libxslt

, colord
, cups
, fontconfig
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
, libpulseaudio
, librsvg
, libwacom
, networkmanager
, polkit
, udev
, upower
, xf86_input_wacom
, xkeyboard_config
, xorg
}:

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
    intltool
    libtool
    libxslt
  ];

  buildInputs = [
    colord
    cups
    fontconfig
    geoclue2
    geocode-glib
    glib
    gnome-desktop
    gnome-themes-standard
    gsettings-desktop-schemas
    gtk3
    ibus
    lcms2
    libcanberra
    libgudev
    libgweather
    libnotify
    libpulseaudio
    librsvg
    libwacom
    networkmanager
    polkit
    udev
    upower
    xf86_input_wacom
    xkeyboard_config
    xorg.libX11
    xorg.libXext
    xorg.libXi
    xorg.libXfixes
    xorg.libxkbfile
    xorg.libXtst
  ];

  NIX_CFLAGS_COMPILE = [
    "-I${glib}/include/gio-unix-2.0"
  ];

  preFixup = ''
    gnomeWrapperArgs+=(
      "--prefix PATH : ${glib}/bin"
    )
  '';

  meta = with stdenv.lib; {
    description = "Gnome Settings Daemon";
    homepage = https://git.gnome.org/browse/gnome-settings-daemon;
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];
  };
}

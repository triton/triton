{ stdenv
, fetchTritonPatch
, fetchurl
, gettext
, intltool
, libtool
, pkgconfig

, atk
, gdk-pixbuf
, geocode-glib
, glib
, gnome-desktop
, gobjectIntrospection
, gsettings-desktop-schemas
, json-glib
, upower
, cairo
, pango
, cogl
, clutter
, libstartup_notification
, libcanberra
, libgudev
, mesa_noglu
, zenity
, xkeyboard_config
, libxkbcommon
, libinput
, systemd
, wayland
, xorg
, gtk3
}:

stdenv.mkDerivation rec {
  name = "mutter-${version}";
  versionMajor = "3.18";
  versionMinor = "2";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/mutter/${versionMajor}/${name}.tar.xz";
    sha256 = "108i4qvwhipdlyvd75fykhskp6y4rywkhffmdknpaxbc45pk4sca";
  };

  patches = [
    (fetchTritonPatch {
      rev = "a8b7a446ebff3620af184177b8f07a9f82167b14";
      file = "mutter/math.patch";
      sha256 = "8c29cc1d5e414583d9a27884dda09a5bbab7b76cf8598145c2c818b3cf95a273";
    })
    (fetchTritonPatch {
      rev = "a8b7a446ebff3620af184177b8f07a9f82167b14";
      file = "mutter/x86.patch";
      sha256 = "0f7438b60b8c32b9f788245273081c4181eb529610ca804c5ba46d12338b1475";
    })
  ];

  nativeBuildInputs = [
    gettext
    pkgconfig
    intltool
    libtool
  ];

  buildInputs = [
    atk
    cairo
    clutter
    cogl
    gdk-pixbuf
    geocode-glib
    glib
    gnome-desktop
    gobjectIntrospection
    gsettings-desktop-schemas
    gtk3
    json-glib
    libcanberra
    libgudev
    libinput
    libstartup_notification
    libxkbcommon
    mesa_noglu
    pango
    systemd
    upower
    wayland
    xkeyboard_config
    xorg.libICE
    xorg.libSM
    xorg.libX11
    xorg.libxcb
    xorg.libXcomposite
    xorg.libXcursor
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXi
    xorg.libXinerama
    xorg.libxkbfile
    xorg.libXrandr
    xorg.libXrender
    zenity
  ];

  configureFlags = [
    "--enable-nls"
    "--enable-glibtest"
    "--enable-schemas-compile"
    "--enable-verbose-mode"
    "--enable-sm"
    "--enable-startup-notification"
    "--disable-installed-tests"
    "--enable-introspection"
    "--enable-native-backend"
    "--enable-wayland"
    "--disable-debug"
    "--enable-compile-warnings"
    "--with-libcanberra"
    "--with-x"
  ];

  NIX_CFLAGS_COMPILE = [
    "-I${glib}/include/gio-unix-2.0"
  ];

  meta = with stdenv.lib; {
    description = "GNOME 3 compositing window manager based on Clutter";
    homepage = https://git.gnome.org/browse/mutter/;
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

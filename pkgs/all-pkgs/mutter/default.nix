{ stdenv
, fetchTritonPatch
, fetchurl
, gettext
, intltool
, libtool

, atk
, gdk-pixbuf
, geocode-glib
, glib
, gnome-desktop
, gobject-introspection
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

with {
  inherit (stdenv.lib)
    enFlag;
};

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
      rev = "9e67dfb8cbcb8c314fee112e2b751dd907cec544";
      file = "mutter/math.patch";
      sha256 = "8c29cc1d5e414583d9a27884dda09a5bbab7b76cf8598145c2c818b3cf95a273";
    })
    (fetchTritonPatch {
      rev = "9e67dfb8cbcb8c314fee112e2b751dd907cec544";
      file = "mutter/x86.patch";
      sha256 = "0f7438b60b8c32b9f788245273081c4181eb529610ca804c5ba46d12338b1475";
    })
    (fetchTritonPatch {
      rev = "9e67dfb8cbcb8c314fee112e2b751dd907cec544";
      file = "mutter/mutter-3.18.2-bypass-hint.patch";
      sha256 = "5743a64e088d61706f9ab70ae8bc0b97bd6633825bfda7bc68fc6c593bd43353";
    })
    (fetchTritonPatch {
      rev = "9e67dfb8cbcb8c314fee112e2b751dd907cec544";
      file = "mutter/mutter-3.18.2-cursor-renderer.patch";
      sha256 = "0264b85181a489615984d5b3098b5b1747214c0d05fb9d725b8b2b85819a0c06";
    })
    (fetchTritonPatch {
      rev = "9e67dfb8cbcb8c314fee112e2b751dd907cec544";
      file = "mutter/mutter-3.18.2-logical-monitors.patch";
      sha256 = "8446922fe20b8c35cfdd891e393d936316530d02ac9b00e61abc0b6e465cf61f";
    })
    (fetchTritonPatch {
      rev = "9e67dfb8cbcb8c314fee112e2b751dd907cec544";
      file = "mutter/mutter-3.18.2-wayland-crash.patch";
      sha256 = "5ad07d72ef05954a53b3e7679ad607621c6076749af431b4ae3c58698731910a";
    })
    (fetchTritonPatch {
      rev = "9e67dfb8cbcb8c314fee112e2b751dd907cec544";
      file = "mutter/mutter-3.18.2-configure-notify.patch";
      sha256 = "474b01c8bd0c14fe04645c8e0cb7e45b9fb4b37c876c11a8545a6ed1c7a7bd59";
    })
  ];

  nativeBuildInputs = [
    gettext
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
    gobject-introspection
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
    (enFlag "introspection" (gobject-introspection != null) null)
    "--enable-native-backend"
    "--enable-wayland"
    "--disable-debug"
    "--enable-compile-warnings"
    "--with-libcanberra"
    "--with-x"
  ];

  preFixup =
    /* Add a symlink to make sure the gobject-introspection hook
       adds typelibs to GI_TYPELIB_PATH */ ''
      if [[ ! -d "$out/lib/girepository-1.0" && -d "$out/lib/mutter" ]] ; then
        ln -svf \
          $out/lib/mutter \
          $out/lib/girepository-1.0
      fi
    '';

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

{ stdenv
, fetchTritonPatch
, fetchurl
, gettext
, intltool
, libtool
, makeWrapper

, atk
, dconf
, gdk-pixbuf
, geocode-glib
, glib
, gnome-desktop
, gnome-settings-daemon
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
, libxkbcommon
, libinput
, systemd_lib
, wayland
, wayland-protocols
, xorg
, gtk3
}:

let
  inherit (stdenv.lib)
    enFlag
    optionals
    wtFlag;
in

assert xorg != null ->
  xorg.libICE != null
  && xorg.libSM != null
  && xorg.libX11 != null
  && xorg.libxcb != null
  && xorg.libXcomposite != null
  && xorg.libXcursor != null
  && xorg.libXdamage != null
  && xorg.libXext != null
  && xorg.libXfixes != null
  && xorg.libXi != null
  && xorg.libXinerama != null
  && xorg.libxkbfile != null
  && xorg.libXrandr != null
  && xorg.libXrender != null
  && xorg.xkeyboardconfig != null;

stdenv.mkDerivation rec {
  name = "mutter-${version}";
  versionMajor = "3.20";
  versionMinor = "3";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/mutter/${versionMajor}/${name}.tar.xz";
    sha256Url = "mirror://gnome/sources/mutter/${versionMajor}/${name}.sha256sum";
    sha256 = "142c5271df4bde968c725ed09026173292c07b4dd7ba75f19c4b14fc363af916";
  };

  nativeBuildInputs = [
    gettext
    intltool
    libtool
    makeWrapper
  ];

  buildInputs = [
    atk
    cairo
    clutter
    cogl
    dconf
    gdk-pixbuf
    geocode-glib
    glib
    gnome-desktop
    gnome-settings-daemon
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
    systemd_lib
    upower
    wayland
    wayland-protocols
    zenity
  ] ++ optionals (xorg != null) [
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
    xorg.xkeyboardconfig
    xorg.xproto
  ];

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
  ];

  configureFlags = [
    "--enable-nls"
    "--enable-glibtest"
    "--enable-schemas-compile"
    "--enable-verbose-mode"
    "--enable-sm"
    (enFlag "startup-notification" (libstartup_notification != null) null)
    "--disable-installed-tests"
    (enFlag "introspection" (gobject-introspection != null) null)
    "--enable-native-backend"
    (enFlag "wayland" (wayland != null) null)
    "--disable-debug"
    "--enable-compile-warnings"
    (wtFlag "libcanberra" (libcanberra != null) null)
    (wtFlag "x" (xorg != null) null)
  ];

  preFixup =
    /* Add a symlink to make sure the gobject-introspection hook
       adds typelibs to GI_TYPELIB_PATH */ ''
      if [[ ! -d "$out/lib/girepository-1.0" && -d "$out/lib/mutter" ]] ; then
        ln -svf \
          $out/lib/mutter \
          $out/lib/girepository-1.0
      fi

      wrapProgram $out/bin/mutter \
        --set 'GSETTINGS_BACKEND' 'dconf' \
        --prefix 'GIO_EXTRA_MODULES' : "$GIO_EXTRA_MODULES" \
        --prefix 'GI_TYPELIB_PATH' : "$GI_TYPELIB_PATH" \
        --prefix 'XDG_DATA_DIRS' : "$GSETTINGS_SCHEMAS_PATH" \
        --prefix 'XDG_DATA_DIRS' : "$out/share" \
        --prefix 'XDG_DATA_DIRS' : "$XDG_ICON_DIRS"
    '';

  meta = with stdenv.lib; {
    description = "GNOME 3 compositing window manager based on Clutter";
    homepage = https://git.gnome.org/browse/mutter/;
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };

}

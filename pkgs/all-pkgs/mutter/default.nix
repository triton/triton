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
  versionMinor = "3";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/mutter/${versionMajor}/${name}.tar.xz";
    sha256 = "0ik8aa3k5cglz9f237mfxxdf8pcr0srr5mmfwdx3gc3bb7aqipaq";
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
    zenity
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

      wrapProgram $out/bin/mutter \
        --set 'GI_TYPELIB_PATH' "$GI_TYPELIB_PATH" \
        --set 'GSETTINGS_BACKEND' 'dconf' \
        --prefix 'GIO_EXTRA_MODULES' : "$GIO_EXTRA_MODULES" \
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
      i686-linux
      ++ x86_64-linux;
  };

}

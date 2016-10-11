{ stdenv
, fetchTritonPatch
, fetchurl
, gettext
, intltool
, libtool
, makeWrapper

, atk
, cairo
, clutter
, cogl
, dconf
, gdk-pixbuf
, geocode-glib
, glib
, gnome-desktop
, gnome-settings-daemon
, gobject-introspection
, gsettings-desktop-schemas
, gtk
, json-glib
, libcanberra
, libdrm
, libgudev
, libinput
, libstartup_notification
, libxkbcommon
, linux-headers_4-6
, mesa_noglu
, pango
, systemd_lib
, upower
, wayland
, wayland-protocols
, xorg
, zenity

, channel
}:

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

let
  inherit (stdenv.lib)
    boolEn
    boolWt
    optionals;

  source = (import ./sources.nix { })."${channel}";
in
stdenv.mkDerivation rec {
  name = "mutter-${source.version}";

  src = fetchurl {
    url = "mirror://gnome/sources/mutter/${channel}/${name}.tar.xz";
    hashOutput = false;
    inherit (source) sha256;
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
    gtk
    json-glib
    libcanberra
    libdrm
    libgudev
    libinput
    libstartup_notification
    libxkbcommon
    linux-headers_4-6
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
    "--${boolEn (libstartup_notification != null)}-startup-notification"
    "--disable-installed-tests"
    "--${boolEn (gobject-introspection != null)}-introspection"
    "--enable-native-backend"
    "--${boolEn (wayland != null)}-wayland"
    "--disable-debug"
    "--enable-compile-warnings"
    "--${boolWt (libcanberra != null)}-libcanberra"
    "--${boolWt (xorg != null)}-x"
  ];

  preFixup =
    /* Add a symlink to make sure the gobject-introspection hook
       adds typelibs to GI_TYPELIB_PATH */ ''
      if [[ ! -d "$out/lib/girepository-1.0" && -d "$out/lib/mutter" ]] ; then
        ln -svf \
          $out/lib/mutter \
          $out/lib/girepository-1.0
      fi
    '' + ''
      wrapProgram $out/bin/mutter \
        --set 'GSETTINGS_BACKEND' 'dconf' \
        --prefix 'GIO_EXTRA_MODULES' : "$GIO_EXTRA_MODULES" \
        --prefix 'GI_TYPELIB_PATH' : "$GI_TYPELIB_PATH" \
        --prefix 'XDG_DATA_DIRS' : "$GSETTINGS_SCHEMAS_PATH" \
        --prefix 'XDG_DATA_DIRS' : "$out/share" \
        --prefix 'XDG_DATA_DIRS' : "$XDG_ICON_DIRS"
    '';

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      sha256Url = "https://download.gnome.org/sources/mutter/${channel}/"
        + "${name}.sha256sum";
      failEarly = true;
    };
  };

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

{ stdenv
, autoreconfHook
, fetchpatch
, fetchTritonPatch
, fetchurl
, gettext
, intltool
, lib
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
, libice
, libinput
, libsm
, libstartup_notification
, libwacom
, libx11
, libxcb
, libxcomposite
, libxcursor
, libxdamage
, libxext
, libxfixes
, libxi
, libxinerama
, libxkbcommon
, libxkbfile
, libxrandr
, libxrender
, libxtst
, linux-headers
, opengl-dummy
, pango
, pipewire
, systemd_lib
, upower
, wayland
, wayland-protocols
, xkeyboard-config
, xorg
, xorg-server
, xorgproto
, zenity

, channel
}:

let
  inherit (lib)
    boolEn
    boolWt;

  sources = {
    "3.26" = {
      version = "3.26.2";
      sha256 = "83309feb05a4635c47713665c0592af8ab6d7f17a36e4bd626d67609b6422fab";
    };
  };
  source = sources."${channel}";
in
stdenv.mkDerivation rec {
  name = "mutter-${source.version}";

  src = fetchurl {
    url = "mirror://gnome/sources/mutter/${channel}/${name}.tar.xz";
    hashOutput = false;
    inherit (source) sha256;
  };

  nativeBuildInputs = [
    autoreconfHook  # Remove once Pipewire 0.1.8 patch is removed.
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
    libice
    libinput
    libsm
    libstartup_notification
    libwacom
    libx11
    libxcb
    libxcomposite
    libxcursor
    libxdamage
    libxext
    libxfixes
    libxi
    libxinerama
    libxkbcommon
    libxkbfile
    libxrandr
    libxrender
    libxtst
    linux-headers
    opengl-dummy
    pango
    pipewire
    systemd_lib
    upower
    wayland
    wayland-protocols
    xkeyboard-config
    xorgproto
    zenity
  ];

  configureFlags = [
    "--enable-nls"
    "--disable-glibtest"
    "--disable-schemas-compile"
    "--enable-verbose-mode"
    "--enable-sm"
    "--${boolEn (libstartup_notification != null)}-startup-notification"
    "--disable-installed-tests"
    "--${boolEn (pipewire != null)}-remote-desktop"
    "--${boolEn (gobject-introspection != null)}-introspection"
    "--enable-native-backend"
    "--enable-egl-device"
    "--${boolEn (wayland != null)}-wayland"
    "--disable-debug"
    "--enable-compile-warnings"
    "--${boolWt (libcanberra != null)}-libcanberra"
    "--${boolWt (libwacom != null)}-libwacom"
    "--${boolWt (libgudev != null)}-gudev"
    # FIXME
    "--${boolWt (wayland != null)}-xwayland-path=${xorg-server}/bin/Xwayland"
    "--${boolWt (libx11 != null)}-x"
  ];

  patches = [
    # Fix compat with Pipewire >=0.1.8
    (fetchpatch {
      url = "https://github.com/GNOME/mutter/commit/c063d43be84dd445a02700c7bb1bf77aea65bb61.patch";
      sha256 = "e6b6eba0149444ed83483c08af186482f06788b4d4399af4117e7c75022ddc3a";
    })
  ];

  NIX_CFLAGS_COMPILE = [
    # FIXME: Autoconf macro is failing to detect xrandr version
    "-DHAVE_XRANDR15"
  ];

  preFixup =
    /* Add a symlink to make sure the gobject-introspection hook
       adds typelibs to GI_TYPELIB_PATH */ ''
    ln -svf $out/lib/mutter/ $out/lib/girepository-1.0
  '' + ''
    wrapProgram $out/bin/mutter \
      --set 'GDK_PIXBUF_MODULE_FILE' "${gdk-pixbuf.loaders.cache}" \
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

  meta = with lib; {
    description = "Compositing window manager based on Clutter";
    homepage = https://git.gnome.org/browse/mutter/;
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };

}

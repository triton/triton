{ stdenv
, autoreconfHook
, fetchurl
, gettext
, intltool
, lib
, libxslt
, which

, atk
, gdk-pixbuf
, glib
, gnome_doc_utils
, gnome-common
, gobject-introspection
, gsettings-desktop-schemas
, gtk
, iso-codes
, itstool
, libseccomp
, libx11
, libxext
, libxml2
, libxrandr
, pango
, python
, randrproto
, systemd_lib
, wayland
, xorg
, xproto

, channel
}:

assert libx11 != null ->
  xorg.libxkbfile != null
  && xorg.xkeyboardconfig != null;

let
  inherit (lib)
    boolEn
    boolWt
    optionals;

  sources = {
    "3.26" = {
      version = "3.26.2";
      sha256 = "f7561a7a313fc474b2c390cd9696df1f5c1e1556080e43f4afe042b1060e5f2a";
    };
  };
  source = sources."${channel}";
in
stdenv.mkDerivation rec {
  name = "gnome-desktop-${source.version}";

  src = fetchurl {
    url = "mirror://gnome/sources/gnome-desktop/${channel}/${name}.tar.xz";
    hashOutput = false;
    inherit (source) sha256;
  };

  nativeBuildInputs = [
    autoreconfHook
    gettext
    gnome-common
    intltool
    itstool
    libxslt
    which
  ];

  buildInputs = [
    atk
    gdk-pixbuf
    glib
    gobject-introspection
    gsettings-desktop-schemas
    gtk
    iso-codes
    libseccomp
    libx11
    libxext
    libxml2
    libxrandr
    pango
    randrproto
    systemd_lib
    xproto
  ] ++ optionals (libx11 != null) [
    xorg.libxkbfile
    xorg.xkeyboardconfig
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--enable-nls"
    "--disable-date-in-gnome-version"
    "--enable-compile-warnings"
    "--disable-iso-c"
    "--disable-deprecation-flags"
    "--disable-desktop-docs"
    "--disable-debug-tools"
    "--disable-installed-tests"
    "--disable-always-build-tests"
    "--${boolEn (systemd_lib != null)}-udev"
    "--${boolEn (gobject-introspection != null)}-introspection"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    "--${boolWt (libx11 != null)}-x"
  ];

  postPatch = /* FIXME: find way to support bwrap */ ''
    sed -i configure.ac \
      -e '/HAVE_BWRAP/d'
  '' + /* Fix hardcoded bubblewrap paths */ ''
    sed -i libgnome-desktop/gnome-desktop-thumbnail-script.c \
      -e '/\/lib64/d' \
      -e "/--ro-bind/ s,/usr,${gdk-pixbuf}," \
      -e "/--symlink/ s,usr/bin,${gdk-pixbuf}/bin,g" \
      -e "/--ro-bind/ s,/lib,${gdk-pixbuf}/lib," \
      -e '/usr\/sbin/d'
  '';

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      sha256Url = "https://download.gnome.org/sources/gnome-desktop/${channel}/"
        + "${name}.sha256sum";
      failEarly = true;
    };
  };

  meta = with lib; {
    description = "Libraries for the gnome desktop that are not part of the UI";
    homepage = https://git.gnome.org/browse/gnome-desktop;
    license = with licenses; [
      #fdl11
      gpl2Plus
      lgpl2Plus
    ];
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

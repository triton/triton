{ stdenv
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
  xorg.libXrandr != null
  && xorg.libxkbfile != null
  && xorg.xkeyboardconfig != null;

let
  inherit (lib)
    boolEn
    boolWt
    optionals;

  sources = {
    "3.26" = {
      version = "3.26.1";
      sha256 = "92fa697af986fb2c6bc6595f0155c968c17e5d1981a50584ff4fb6fd60124e2f";
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
    gettext
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

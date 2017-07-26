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
, libx11
, libxext
, libxml2
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
    "3.24" = {
      version = "3.24.2";
      sha256 = "8fa1de66a6a75963bffc79b01a60434c71237d44c51beca09c0f714a032d785e";
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
    libx11
    libxext
    libxml2
    pango
    randrproto
    systemd_lib
    xproto
  ] ++ optionals (libx11 != null) [
    xorg.libXrandr
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

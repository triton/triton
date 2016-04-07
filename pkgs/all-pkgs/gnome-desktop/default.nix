{ stdenv
, fetchurl
, gettext
, intltool
, libxslt
, which

, atk
, gdk-pixbuf
, glib
, gnome_doc_utils
, gobject-introspection
, gsettings-desktop-schemas
, gtk3
, iso-codes
, itstool
, libxml2
, pango
, python
, wayland
, xorg
}:

let
  inherit (stdenv.lib)
    enFlag
    optionals
    wtFlag;
in

assert xorg != null ->
  xorg.libX11 != null
  && xorg.libXext != null
  && xorg.libXrandr != null
  && xorg.randrproto != null
  && xorg.xkeyboardconfig != null
  && xorg.xproto != null;

stdenv.mkDerivation rec {
  name = "gnome-desktop-${version}";
  versionMajor = "3.20";
  versionMinor = "0";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/gnome-desktop/${versionMajor}/${name}.tar.xz";
    sha256 = "18c7f818cfd91e25d242785c14d0d46dd8eeca3a0bde46949d387987badab08d";
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
    gtk3
    iso-codes
    libxml2
    pango
  ] ++ optionals (xorg != null) [
    xorg.libX11
    xorg.libXext
    xorg.libxkbfile
    xorg.libXrandr
    xorg.randrproto
    xorg.xkeyboardconfig
    xorg.xproto
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
    (enFlag "introspection" (gobject-introspection != null) null)
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    (wtFlag "x" (xorg != null) null)
  ];

  meta = with stdenv.lib; {
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

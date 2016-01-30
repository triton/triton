{ stdenv
, fetchurl
, gettext
, intltool
, libxslt
, which

, glib
, gnome_doc_utils
, gobject-introspection
, gsettings-desktop-schemas
, gtk3
, isocodes
, itstool
, libxml2Python
, python
, wayland
, xkeyboard_config
, xorg
}:

with {
  inherit (stdenv.lib)
    enFlag
    wtFlag;
};

assert xorg != null ->
  xorg.libX11 != null &&
  xorg.libXext != null &&
  xorg.libXrandr != null &&
  xorg.randrproto != null &&
  xorg.xproto != null;

stdenv.mkDerivation rec {
  name = "gnome-desktop-${version}";
  versionMajor = "3.18";
  versionMinor = "2";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/gnome-desktop/${versionMajor}/${name}.tar.xz";
    sha256 = "0mkv5vg04n2znd031dgjsgari6rgnf97637mf4x58dz15l16vm6x";
  };

  nativeBuildInputs = [
    gettext
    intltool
    libxslt
    which
  ];

  buildInputs = [
    glib
    gnome_doc_utils
    gobject-introspection
    gsettings-desktop-schemas
    gtk3
    isocodes
    itstool
    libxml2Python
    python
    wayland
    xkeyboard_config
    xorg.libX11
    xorg.libXext
    xorg.libxkbfile
    xorg.libXrandr
    xorg.randrproto
    xorg.xproto
  ];

  configureFlags = [
    "--enable-nls"
    "--disable-date-in-gnome-version"
    "--enable-compile-warnings"
    (enFlag "introspection" (gobject-introspection != null) null)
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    (wtFlag "x" (xorg != null) null)
  ];

  NIX_CFLAGS_COMPILE = [
    "-I${glib}/include/gio-unix-2.0"
  ];

  meta = with stdenv.lib; {
    description = "Libraries for the gnome desktop that are not part of the UI";
    homepage = https://git.gnome.org/browse/gnome-desktop;
    license = with licenses; [
      gpl2Plus
      fdl11
      lgpl2Plus
    ];
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];
  };
}

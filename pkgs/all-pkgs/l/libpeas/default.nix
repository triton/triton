{ stdenv
, fetchurl
, gettext
, intltool

, atk
, gdk-pixbuf
, glib
, gobject-introspection
, gtk3
, pango
, python3
, python3Packages
}:

let
  inherit (stdenv.lib)
    enFlag;
in

stdenv.mkDerivation rec {
  name = "libpeas-${version}";
  versionMajor = "1.18";
  versionMinor = "0";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome-insecure/sources/libpeas/${versionMajor}/${name}.tar.xz";
    sha256 = "bf49842c64c36925bbc41d954de490b6ff7faa29b45f6fd9e91ddcc779165e26";
  };

  nativeBuildInputs = [
    gettext
    intltool
  ];

  buildInputs =  [
    atk
    gdk-pixbuf
    glib
    gobject-introspection
    gtk3
    pango
    python3
    python3Packages.pygobject3
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--enable-nls"
    (enFlag "gtk" (gtk3 != null) null)
    # Flag is not a Boolean
    #"--disable-gcov"
    "--disable-glade-catalog"
    "--disable-lua5.1"
    "--disable-luajit"
    "--disable-python2"
    (enFlag "python3" (python3 != null) null)
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    "--disable-doc-cross-references"
    "--enable-compile-warnings"
    "--disable-iso-c"
  ];

  meta = with stdenv.lib; {
    description = "A GObject plugins library";
    homepage = "https://developer.gnome.org/libpeas/stable/";
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

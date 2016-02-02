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
, pygobject3
}:

with {
  inherit (stdenv.lib)
    enFlag;
};

stdenv.mkDerivation rec {
  name = "libpeas-${version}";
  versionMajor = "1.16";
  versionMinor = "0";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/libpeas/${versionMajor}/${name}.tar.xz";
    sha256 = "b093008ecd65f7d55c80517589509698ff15ad41f664b11a3eb88ff461b1454e";
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
    pygobject3
    python3
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
    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];
  };
}

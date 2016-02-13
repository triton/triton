{ stdenv
, fetchurl
, intltool

, atk
, cairo
, gdk-pixbuf
, glib
, gobject-introspection
, gtk3
, libxml2
, ncurses
, pango
, xorg
, zlib
}:

with {
  inherit (stdenv.lib)
    enFlag;
};

stdenv.mkDerivation rec {
  name = "vte-${version}";
  versionMajor = "0.36";
  versionMinor = "5";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/vte/${versionMajor}/${name}.tar.xz";
    sha256 = "1psfnqsmxx4qzc55qwvb8jai824ix4pqcdqhgxk0g2zh82bcxhn2";
  };

  nativeBuildInputs = [
    intltool
  ];

  buildInputs = [
    atk
    cairo
    gdk-pixbuf
    glib
    gobject-introspection
    gtk3
    libxml2
    ncurses
    pango
    xorg.libX11
    zlib
  ];

  postPatch = ''
    patchShebangs src/test-vte-sh.sh
  '';

  configureFlags = [
    "--disable-maintainer-mode"
    "--disable-debug"
    "--enable-nls"
    "--enable-Bsymbolic"
    "--enable-gnome-pty-helper"
    "--disable-glade"
    (enFlag "introspection" (gobject-introspection != null) null)
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
  ];

  doCheck = true;

  meta = with stdenv.lib; {
    description = "A library implementing a terminal emulator widget for GTK+";
    homepage = http://www.gnome.org/;
    license = licenses.lgpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];
  };
}

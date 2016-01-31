{ stdenv
, fetchurl
, intltool

, atk
, gdk-pixbuf-core
, glib
, gnutls
, gobject-introspection
, gtk3
, libxml2
, ncurses
, pango
, pcre2
, vala
, zlib

, selectTextPatch ? false
}:

with {
  inherit (stdenv.lib)
    enFlag
    optional
    wtFlag;
};

stdenv.mkDerivation rec {
  name = "vte-${version}";
  versionMajor = "0.42";
  versionMinor = "3";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/vte/${versionMajor}/${name}.tar.xz";
    sha256 = "1832mrw2hhgjipbsfsv2fmdnwnar4rkx589ciz008bg8x908mscn";
  };

  nativeBuildInputs = [
    intltool
  ];

  buildInputs = [
    atk
    gdk-pixbuf-core
    glib
    gnutls
    gtk3
    libxml2
    ncurses
    gobject-introspection
    pango
    pcre2
    vala
    zlib
  ];

  patches = [ ]
    ++ optional selectTextPatch ./expose_select_text.0.40.0.patch;

  postPatch = ''
    patchShebangs ./src/box_drawing_generate.sh
    patchShebangs ./src/check-libstdc++.sh
    patchShebangs ./src/test-vte-sh.sh
  '';

  configureFlags = [
    "--disable-maintainer-mode"
    "--disable-debug"
    "--enable-nls"
    "--enable-Bsymbolic"
    "--disable-glade"
    (enFlag "introspection" (gobject-introspection != null) null)
    (enFlag "vala" (vala != null) null)
    # test application uses deprecated functions
    "--disable-test-application"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    (wtFlag "gnutls" (gnutls != null) null)
    (wtFlag "pcre2" (pcre2 != null) null)
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

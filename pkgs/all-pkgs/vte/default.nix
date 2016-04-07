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

let
  inherit (stdenv.lib)
    enFlag
    optional
    wtFlag;
in

stdenv.mkDerivation rec {
  name = "vte-${version}";
  versionMajor = "0.44";
  versionMinor = "0";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/vte/${versionMajor}/${name}.tar.xz";
    sha256 = "93a3b1a71a885f416a119a5a8fb27b8f36bb176b8d0bec5e48188d1db5ef12aa";
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

  doCheck = false;

  meta = with stdenv.lib; {
    description = "A library implementing a terminal emulator widget for GTK+";
    homepage = http://www.gnome.org/;
    license = licenses.lgpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

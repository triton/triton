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
  versionMinor = "1";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/vte/${versionMajor}/${name}.tar.xz";
    sha256Url = "mirror://gnome/sources/vte/${versionMajor}/${name}.sha256sum";
    sha256 = "712dd548339f600fd7e221d12b2670a13a4361b2cd23ba0e057e76cc19fe5d4e";
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

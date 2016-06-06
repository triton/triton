{ stdenv
, fetchurl
, intltool

, atk
, gdk-pixbuf_unwrapped
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
  versionMinor = "2";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/vte/${versionMajor}/${name}.tar.xz";
    sha256Url = "mirror://gnome/sources/vte/${versionMajor}/${name}.sha256sum";
    sha256 = "a1ea594814bb136a3a9a6c7656b46240571f6a198825c1111007fe99194b0949";
  };

  nativeBuildInputs = [
    intltool
  ];

  buildInputs = [
    atk
    gdk-pixbuf_unwrapped
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

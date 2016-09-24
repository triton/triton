{ stdenv
, fetchurl
, intltool

, atk
, gdk-pixbuf_unwrapped
, glib
, gnutls
, gobject-introspection
, gtk
, libxml2
, ncurses
, pango
, pcre2
, vala
, zlib

, channel
}:

let
  inherit (stdenv.lib)
    boolEn
    boolWt
    optional;

  source = (import ./sources.nix { })."${channel}";
in
stdenv.mkDerivation rec {
  name = "vte-${source.version}";

  src = fetchurl {
    url = "mirror://gnome/sources/vte/${channel}/${name}.tar.xz";
    hashOutput = false;
    inherit (source) sha256;
  };

  nativeBuildInputs = [
    intltool
  ];

  buildInputs = [
    atk
    gdk-pixbuf_unwrapped
    glib
    gnutls
    gtk
    libxml2
    ncurses
    gobject-introspection
    pango
    pcre2
    vala
    zlib
  ];

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
    "--${boolEn (gobject-introspection != null)}-introspection"
    "--${boolEn (vala != null)}-vala"
    # test application uses deprecated functions
    "--disable-test-application"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    "--${boolWt (gnutls != null)}-gnutls"
  ];

  doCheck = false;

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      sha256Url = "https://download.gnome.org/sources/vte/${channel}/"
        + "${name}.sha256sum";
      failEarly = true;
    };
  };

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

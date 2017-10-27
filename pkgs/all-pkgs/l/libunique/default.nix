{ stdenv
, docbook_xml_dtd_45
, docbook-xsl
, fetchurl
, gtk-doc
, lib
, libxslt

, atk
, dbus
, dbus-glib
, gdk-pixbuf
, glib
, gobject-introspection
, gtk_3
, libx11
, libxml2
, pango
}:

let
  inherit (lib)
    boolEn
    boolWt;

  channel = "3.0";
  version = "${channel}.2";
in
stdenv.mkDerivation rec {
  name = "libunique-${version}";

  src = fetchurl {
    url = "mirror://gnome/sources/libunique/${channel}/${name}.tar.xz";
    sha256 = "0f70lkw66v9cj72q0iw1s2546r6bwwcd8idcm3621fg2fgh2rw58";
  };

  nativeBuildInputs = [
    docbook_xml_dtd_45
    docbook-xsl
    gtk-doc
    libxslt
  ];

  buildInputs = [
    atk
    dbus
    dbus-glib
    gdk-pixbuf
    glib
    gtk_3
    gobject-introspection
    libx11
    libxml2
    pango
  ];

  configureFlags = [
    "--enable-glibtest"
    "--${boolEn (dbus-glib != null)}-dbus"
    "--enable-bacon"
    "--disable-maintainer-flags"
    "--disable-debug"
    "--${boolEn (gobject-introspection != null)}-introspection"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    "--${boolWt (libx11 != null)}-x"
  ];

  meta = with lib; {
    description = "A library for writing single instance applications";
    homepage = http://live.gnome.org/LibUnique;
    license = licenses.lgpl21;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

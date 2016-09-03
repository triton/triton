{ stdenv
, docbook_xml_dtd_45
, docbook-xsl
, fetchurl
, gtk-doc
, libxslt

, atk
, dbus
, dbus-glib
, gdk-pixbuf
, glib
, gobject-introspection
, gtk3
, libxml2
, pango
, xorg
}:

let
  inherit (stdenv.lib)
    enFlag
    wtFlag;
in

assert xorg != null -> xorg.libX11 != null;

stdenv.mkDerivation rec {
  name = "libunique-${version}";
  versionMajor = "3.0";
  versionMinor = "2";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome-insecure/sources/libunique/${versionMajor}/${name}.tar.xz";
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
    gtk3
    gobject-introspection
    libxml2
    pango
    xorg.libX11
  ];

  configureFlags = [
    "--enable-glibtest"
    (enFlag "dbus" (dbus-glib != null) null)
    "--enable-bacon"
    "--disable-maintainer-flags"
    "--disable-debug"
    (enFlag "introspection" (gobject-introspection != null) null)
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    (wtFlag "x" (xorg != null) null)
  ];

  meta = with stdenv.lib; {
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

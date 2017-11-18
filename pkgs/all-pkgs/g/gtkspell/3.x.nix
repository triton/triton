{ stdenv
, fetchurl
, intltool
, lib

, aspell
, atk
, enchant
, gdk-pixbuf
, glib
, gobject-introspection
, gtk2
, gtk3
, iso-codes
, pango
, vala
}:

let
  version = "3.0.7";
in
stdenv.mkDerivation rec {
  name = "gtkspell-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/gtkspell/gtkspell3-${version}.tar.gz";
    sha256 = "1hiwzajf18v9ik4nai3s7frps4ccn9s20nggad1c4k2mwb9ydwhk";
  };

  nativeBuildInputs = [
    intltool
    vala
  ];

  buildInputs = [
    aspell
    atk
    enchant
    gdk-pixbuf
    glib
    gobject-introspection
    gtk2
    gtk3
    iso-codes
    pango
  ];

  configureFlags = [
    "--enable-gtk2"
    "--enable-gtk3"
    "--enable-introspection"
    "--enable-vala"
    "--enable-nls"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    "--enable-iso-codes"
  ];

  meta = with lib; {
    description = "Word-processor-style highlighting GtkTextView widget";
    homepage = "http://gtkspell.sourceforge.net/";
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

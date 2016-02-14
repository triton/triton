{ stdenv
, fetchurl
, intltool

, aspell
, atk
, enchant
, gdk-pixbuf
, glib
, gobject-introspection
, gtk2
, gtk3
, isocodes
, pango
, vala
}:

with {
  inherit (stdenv.lib)
    enFlag;
};

stdenv.mkDerivation rec {
  name = "gtkspell-${version}";
  version = "3.0.7";

  src = fetchurl {
    url = "mirror://sourceforge/gtkspell/gtkspell3-${version}.tar.gz";
    sha256 = "1hiwzajf18v9ik4nai3s7frps4ccn9s20nggad1c4k2mwb9ydwhk";
  };

  nativeBuildInputs = [
    intltool
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
    isocodes
    pango
    vala
  ];

  configureFlags = [
    (enFlag "gtk2" (gtk2 != null) null)
    (enFlag "gtk3" (gtk3 != null) null)
    (enFlag "introspection" (gobject-introspection != null) null)
    (enFlag "vala" (vala != null) null)
    "--enable-nls"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    (enFlag "iso-codes" (isocodes != null) null)
  ];

  meta = with stdenv.lib; {
    description = "Word-processor-style highlighting GtkTextView widget";
    homepage = "http://gtkspell.sourceforge.net/";
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}

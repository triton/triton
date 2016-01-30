{ stdenv
, fetchurl
, intltool

, aspell
, enchant
, gtk2
}:

stdenv.mkDerivation {
  name = "gtkspell-2.0.16";

  src = fetchurl {
    url = mirror://sourceforge/gtkspell/gtkspell-2.0.16.tar.gz;
    sha256 = "00hdv28bp72kg1mq2jdz1sdw2b8mb9iclsp7jdqwpck705bdriwg";
  };

  nativeBuildInputs = [
    intltool
  ];

  buildInputs = [
    aspell
    enchant
    gtk2
  ];

  configureFlags = [
    "--disable-gtk-doc"
    "--enable-nls"
  ];

  meta = with stdenv.lib; {
    description = "Word-processor-style highlighting GtkTextView widget";
    homepage = "http://gtkspell.sourceforge.net/";
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];
  };
}

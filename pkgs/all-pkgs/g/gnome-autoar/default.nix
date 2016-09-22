{ stdenv
, atk
, gdk-pixbuf
, fetchurl
, pango

, glib
, gobject-introspection
, gtk_3
, libarchive
}:

let
  inherit (stdenv.lib)
    boolEn;

  channel = "0.1";
  version = "${channel}.1";
in
stdenv.mkDerivation rec {
  name = "gnome-autoar-${version}";

  src = fetchurl {
    url = "mirror://gnome/sources/gnome-autoar/${channel}/${name}.tar.xz";
    hashOutput = false;
    sha256 = "f65cb810b562dc038ced739fbf59739fd5df1a8e848636e21f363ded9f349ac9";
  };

  nativeBuildInputs = [
    atk
    gdk-pixbuf
    gobject-introspection
    pango
  ];

  buildInputs = [
    glib
    gtk_3
    libarchive
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--disable-schemas-compile"
    "--disable-debug"
    "--enable-compile-warnings"
    "--disable-iso-c"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    "--${boolEn (gobject-introspection != null)}-gobject-introspection"
    "--${boolEn (gtk_3 != null)}-gtk"
  ];

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      sha256Url = "https://download.gnome.org/sources/gnome-autoar/${channel}/"
        + "${name}.sha256sum";
      failEarly = true;
    };
  };

  meta = with stdenv.lib; {
    description = "A file manager for the GNOME desktop";
    homepage = https://wiki.gnome.org/Apps/Nautilus;
    license = with licenses; [
      fdl11
      gpl2Plus
      lgpl2Plus
    ];
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

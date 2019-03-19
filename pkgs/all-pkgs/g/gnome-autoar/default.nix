{ stdenv
, atk
, cairo
, gdk-pixbuf
, fetchurl
, lib
, pango

, glib
, gobject-introspection
, gtk_3
, libarchive
}:

let
  inherit (lib)
    boolEn;

  channel = "0.2";
  version = "${channel}.3";
in
stdenv.mkDerivation rec {
  name = "gnome-autoar-${version}";

  src = fetchurl {
    url = "mirror://gnome/sources/gnome-autoar/${channel}/${name}.tar.xz";
    hashOutput = false;
    sha256 = "5de9db0db028cd6cab7c2fec46ba90965474ecf9cd68cfd681a6488cf1fb240a";
  };

  nativeBuildInputs = [
    atk
    cairo
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
    "--disable-vala"
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

  meta = with lib; {
    description = "Compressed file management for GNOME application";
    homepage = https://gitlab.gnome.org/GNOME/gnome-autoar;
    license = licenses.lgpl21Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

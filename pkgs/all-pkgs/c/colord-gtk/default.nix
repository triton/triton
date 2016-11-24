{ stdenv
, fetchurl
, intltool

, atk
, colord
, gdk-pixbuf
, glib
, gobject-introspection
, gtk3
, lcms2
, pango
, vala
}:

let
  inherit (stdenv.lib)
    boolEn;
in
stdenv.mkDerivation rec {
  name = "colord-gtk-0.1.26";

  src = fetchurl rec {
    url = "https://www.freedesktop.org/software/colord/releases/${name}.tar.xz";
    sha256 = "28d00b7f157ea3e2ea5315387b2660fde82faba16674861c50465e55d61a3e45";
    hashOutput = false;
  };

  nativeBuildInputs = [
    intltool
  ];

  buildInputs = [
    atk
    colord
    gdk-pixbuf
    glib
    gobject-introspection
    gtk3
    lcms2
    pango
    vala
  ];

  configureFlags = [
    "--${boolEn (gobject-introspection != null)}-introspection"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    "--enable-nls"
    "--disable-strict"
    "--enable-rpath"
    "--enable-schemas-compile"
    "--disable-gtk2"
    "--${boolEn (vala != null)}-vala"
  ];

  CFLAGS = "-Wno-deprecated-declarations";

  passthru = {
    srcVerification = fetchurl rec {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      sha1Urls =  map (n: "${n}.sha1") urls;
      pgpsigUrls = map (n: "${n}.asc") urls;
      pgpKeyFingerprint = "163EB 50119 225DB 3DF8F  49EA1 7ACBA 8DFA9 70E17";
      failEarly = true;
    };
  };

  meta = with stdenv.lib; {
    description = "";
    homepage = https://www.freedesktop.org/software/colord/;
    license = licenses.lgpl2Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

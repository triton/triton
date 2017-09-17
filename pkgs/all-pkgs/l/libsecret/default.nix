{ stdenv
, docbook-xsl
, fetchurl
, intltool
, lib
, libxslt

, glib
, gobject-introspection
, libgcrypt
, vala
}:

let
  inherit (lib)
    boolEn;

  versionMajor = "0.18";
  versionMinor = "5";
  version = "${versionMajor}.${versionMinor}";
in
stdenv.mkDerivation rec {
  name = "libsecret-${version}";

  src = fetchurl {
    url = "mirror://gnome/sources/libsecret/${versionMajor}/${name}.tar.xz";
    sha256 = "9ce7bd8dd5831f2786c935d82638ac428fa085057cc6780aba0e39375887ccb3";
  };

  nativeBuildInputs = [
    intltool
    libxslt
    docbook-xsl
  ];

  buildInputs = [
    glib
    gobject-introspection
    libgcrypt
    vala
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--enable-nls"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    "--enable-introspection"
    "--enable-manpages"
    "--${boolEn (vala != null)}-vala"
    "--enable-gcrypt"
    "--disable-debug"
    "--disable-coverage"
    "--with-libgcrypt-prefix=${libgcrypt}"
  ];

  meta = with lib; {
    description = "GObject library for the freedesktop.org Secret Service API";
    homepage = https://wiki.gnome.org/Projects/Libsecret;
    license = with licenses; [
      #apache20
      lgpl21Plus
    ];
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

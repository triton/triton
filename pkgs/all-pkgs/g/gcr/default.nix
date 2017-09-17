{ stdenv
, fetchurl
, intltool
, lib
, libxslt

, atk
, dbus-glib
, gdk-pixbuf
, glib
, gobject-introspection
, gnupg
, gtk3
, libgcrypt
, libtasn1
, p11-kit
, pango
, vala
}:

let
  inherit (lib)
    boolEn;

  versionMajor = "3.20";
  versionMinor = "0";
  version = "${versionMajor}.${versionMinor}";
in
stdenv.mkDerivation rec {
  name = "gcr-${version}";

  src = fetchurl {
    url = "mirror://gnome/sources/gcr/${versionMajor}/${name}.tar.xz";
    sha256 = "90572c626d8a708225560c42b4421f7941315247fa1679d4ef569bde7f4bb379";
  };

  nativeBuildInputs = [
    intltool
    libxslt
  ];

  buildInputs = [
    atk
    dbus-glib
    gdk-pixbuf
    glib
    gnupg
    gobject-introspection
    gtk3
    libgcrypt
    libtasn1
    p11-kit
    pango
    vala
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--enable-nls"
    "--enable-schemas-compile"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    "--enable-introspection"
    "--${boolEn (vala != null)}-vala"
    "--disable-update-mime"
    "--disable-update-icon-cache"
    "--disable-debug"
    "--disable-coverage"
    "--disable-valgrind"
  ];

  doCheck = false;

  meta = with lib; {
    description = "Libraries for cryptographic UIs and accessing PKCS#11 modules";
    homepage = https://git.gnome.org/browse/gcr;
    license = with licenses; [
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

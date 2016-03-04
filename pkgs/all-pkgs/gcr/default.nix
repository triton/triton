{ stdenv
, fetchurl
, intltool
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
, p11_kit
, pango
, vala
}:

with {
  inherit (stdenv.lib)
    enFlag;
};

stdenv.mkDerivation rec {
  name = "gcr-${version}";
  versionMajor = "3.18";
  versionMinor = "0";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/gcr/${versionMajor}/${name}.tar.xz";
    sha256 = "006f6xbd3jppkf9avg83mpqdld5d0z6mr0sm81lql52mmyjnvlfl";
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
    p11_kit
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
    (enFlag "introspection" (gobject-introspection != null) null)
    (enFlag "vala" (vala != null) null)
    "--disable-update-mime"
    "--disable-update-icon-cache"
    "--disable-debug"
    "--disable-coverage"
    "--disable-valgrind"
  ];

  doCheck = false;

  meta = with stdenv.lib; {
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
      i686-linux
      ++ x86_64-linux;
  };
}

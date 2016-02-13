{ stdenv
, docbook_xsl
, fetchurl
, intltool
, libxslt

, glib
, gobject-introspection
, libgcrypt
, vala
}:

with {
  inherit (stdenv.lib)
    enFlag
    wtFlag;
};

stdenv.mkDerivation rec {
  name = "libsecret-${version}";
  versionMajor = "0.18";
  versionMinor = "4";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/libsecret/${versionMajor}/${name}.tar.xz";
    sha256 = "1v8r180sjppapa2kl4vbaizlb34w27ixqjhzr6cnk3hrk0bbaa8g";
  };

  nativeBuildInputs = [
    intltool
    libxslt
    docbook_xsl
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
    (enFlag "introspection" (gobject-introspection != null) null)
    "--enable-manpages"
    (enFlag "vala" (vala != null) null)
    (enFlag "gcrypt" (libgcrypt != null) null)
    "--disable-debug"
    "--disable-coverage"
    (wtFlag "libgcrypt-prefix" (libgcrypt != null) libgcrypt)
  ];

  meta = with stdenv.lib; {
    description = "GObject library for the freedesktop.org Secret Service API";
    homepage = https://wiki.gnome.org/Projects/Libsecret;
    license = with licenses; [
      apache20
      lgpl21Plus
    ];
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];
  };
}

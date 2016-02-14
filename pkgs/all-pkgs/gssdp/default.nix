{ stdenv
, fetchurl
, gettext

, glib
, gobject-introspection
, gtk3
, libsoup
, vala
}:

with {
  inherit (stdenv.lib)
    enFlag
    wtFlag;
};

stdenv.mkDerivation rec {
  name = "gssdp-${version}";
  versionMajor = "0.14";
  versionMinor = "13";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/gssdp/${versionMajor}/${name}.tar.xz";
    sha256 = "1spag64k1s39xxhk3j73xxp6xz11v8h09dygk3b2m8877h77y1a3";
  };

  nativeBuildInputs = [
    gettext
  ];

  buildInputs = [
    glib
    gobject-introspection
    gtk3
    libsoup
    vala
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--enable-compile-warnings"
    "--enable-introspection"
    (enFlag "introspection" (gobject-introspection != null) null)
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    "--with-gtk"
    (wtFlag "gtk" (gtk3 != null) null)
  ];

  meta = with stdenv.lib; {
    description = "GObject-based API for resource discovery and announcement over SSDP";
    homepage = https://wiki.gnome.org/Projects/GUPnP;
    license = licenses.lgpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}

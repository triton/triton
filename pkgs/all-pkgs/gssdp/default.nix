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
  versionMinor = "14";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/gssdp/${versionMajor}/${name}.tar.xz";
    sha256 = "1mj8bf3a9fcshx9zr498f623fi0mwm3l196xxam293avbdsihmv8";
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
      x86_64-linux;
  };
}

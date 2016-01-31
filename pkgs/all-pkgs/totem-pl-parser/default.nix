{ stdenv
, fetchurl
, gettext
, intltool

, file
, glib
, gmime
, gobject-introspection
, libarchive
, libgcrypt
, libsoup
, libxml2
}:

with {
  inherit (stdenv.lib)
    enFlag
    wtFlag;
};

stdenv.mkDerivation rec {
  name = "totem-pl-parser-${version}";
  versionMajor = "3.10";
  versionMinor = "6";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/totem-pl-parser/${versionMajor}/${name}.tar.xz";
    sha256 = "0mv7aw9mw77w04zg95zjf0zmk6ckshpysbb9nap15h5is6zdk9cq";
  };

  nativeBuildInputs = [
    gettext
    intltool
  ];

  buildInputs = [
    file
    glib
    gmime
    gobject-introspection
    libarchive
    libgcrypt
    libsoup
    libxml2
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--enable-nls"
    "--enable-gmime-i-know-what-im-doing"
    # TODO: quvi support
    "--disable-quvi"
    (enFlag "libarchive" (libarchive != null) null)
    (enFlag "libgcrypt" (libgcrypt != null) null)
    "--disable-debug"
    "--enable-cxx-warnings"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    (enFlag "introspection" (gobject-introspection != null) null)
    "--disable-code-coverage"
    (wtFlag "libgcrypt-prefix" (libgcrypt != null) libgcrypt)
  ];

  meta = with stdenv.lib; {
    description = "GObject library to parse and save playlist formats";
    homepage = https://wiki.gnome.org/Apps/Videos;
    license = licenses.lgpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];
  };
}

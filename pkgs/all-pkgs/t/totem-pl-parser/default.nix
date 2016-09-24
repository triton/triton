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

let
  inherit (stdenv.lib)
    enFlag
    wtFlag;
in

stdenv.mkDerivation rec {
  name = "totem-pl-parser-${version}";
  versionMajor = "3.10";
  versionMinor = "7";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/totem-pl-parser/${versionMajor}/${name}.tar.xz";
    sha256 = "9c8285bc3131faa309d5cba5a919d5166abc2b8cc5a0c850fe861be8b14e089c";
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
    platforms = with platforms;
      x86_64-linux;
  };
}

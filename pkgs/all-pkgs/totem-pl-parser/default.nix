{ stdenv
, fetchurl
, intltool

, file
, glib
, gmime
, gobject-introspection
, libsoup
, libxml2
}:

stdenv.mkDerivation rec {
  name = "totem-pl-parser-${version}";
  versionMajor = "3.10";
  versionMinor = "5";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/totem-pl-parser/${versionMajor}/${name}.tar.xz";
    sha256 = "0dw1kiwmjwdjrighri0j9nagsnj44dllm0mamnfh4y5nc47mhim7";
  };

  nativeBuildInputs = [
    intltool
  ];

  buildInputs = [
    file
    glib
    gmime
    gobject-introspection
    libsoup
    libxml2
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--enable-nls"
    "--enable-gmime-i-know-what-im-doing"
    # TODO: quvi support
    "--disable-quvi"
    # TODO: libarchive support
    "--disable-libarchive"
    # TODO: libgcrypt support
    "--disable-libgcrypt"
    "--disable-debug"
    "--enable-cxx-warnings"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    "--enable-introspection"
    "--disable-code-coverage"
    #"--with-libgcrypt-prefix="
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

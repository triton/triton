{ stdenv
, docbook_xsl
, docbook_xsl_ns
, fetchurl
, gettext
, intltool
, libxslt
, makeWrapper

, dbus_glib
, glib
, gtk3
, libxml2
, vala
}:

stdenv.mkDerivation rec {
  name = "dconf-${version}";
  versionMajor = "0.24";
  versionMinor = "0";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/dconf/${versionMajor}/${name}.tar.xz";
    sha256 = "4373e0ced1f4d7d68d518038796c073696280e22957babb29feb0267c630fec2";
  };

  nativeBuildInputs = [
    gettext
    intltool
    makeWrapper
  ];

  buildInputs = [
    dbus_glib
    glib
    gtk3
    libxml2
    vala
  ];

  configureFlags = [
    "--disable-man"
    "--enable-schemas-compile"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    "--disable-gcov"
  ];

  meta = with stdenv.lib; {
    description = "Simple low-level configuration system";
    homepage = https://wiki.gnome.org/dconf;
    license = licenses.lgpl21Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];
  };
}

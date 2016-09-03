{ stdenv
, docbook-xsl
, docbook-xsl-ns
, fetchurl
, gettext
, intltool
, libxslt
, makeWrapper

, dbus
, dbus-glib
, glib
, gtk3
, libxml2
, vala
}:

stdenv.mkDerivation rec {
  name = "dconf-${version}";
  versionMajor = "0.26";
  versionMinor = "0";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/dconf/${versionMajor}/${name}.tar.xz";
    sha256Url = "mirror://gnome/sources/dconf/${versionMajor}/${name}.sha256sum";
    sha256 = "8683292eb31a3fae31e561f0a4220d8569b0f6d882e9958b68373f9043d658c9";
  };

  nativeBuildInputs = [
    gettext
    intltool
    makeWrapper
  ];

  buildInputs = [
    dbus
    dbus-glib
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
    platforms = with platforms;
      x86_64-linux;
  };
}

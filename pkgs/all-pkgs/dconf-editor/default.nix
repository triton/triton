{ stdenv
, fetchurl
, vala
, libxslt
, glib
, gtk3
, dbus_glib
, libxml2
, intltool
, docbook_xsl_ns
, docbook_xsl
, adwaita-icon-theme
, dconf
}:

stdenv.mkDerivation rec {
  name = "dconf-editor-${version}";
  versionMajor = "3.18";
  versionMinor = "2";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/dconf-editor/${versionMajor}/${name}.tar.xz";
    sha256 = "0xdwi7g1xdmgrc9m8ii62fp2zj114gsfpmgazlnhrcmmfi97z5d7";
  };

  buildInputs = [
    adwaita-icon-theme
    vala
    libxslt
    glib
    dbus_glib
    gtk3
    libxml2
    intltool
    docbook_xsl
    docbook_xsl_ns
    dconf
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = platforms.linux;
  };
}

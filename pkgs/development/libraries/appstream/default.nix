{ stdenv
, cmake
, docbook_xml_dtd_45
, docbook_xsl
, fetchurl
, gettext
, gobject-introspection
, intltool
, xmlto

, glib
, libxml2
, libyaml
, xapian
}:

let
  inherit (lib)
    replaceChars;

  version = "0.11.0";

  versionFormatted = replaceChars ["."] ["_"] version;
in
stdenv.mkDerivation {
  name = "appstream-${version}";

  src = fetchurl {
    url = "https://github.com/ximion/appstream/archive/"
      + "APPSTREAM_${versionFormatted}.tar.gz";
    sha256 = "16a3b38avrwyl1pp8jdgfjv6cd5mccbmk4asni92l40y5r0xfycr";
  };

  nativeBuildInputs = [
    cmake
    gettext
    intltool
    docbook_xsl
    docbook_xml_dtd_45
    gobject-introspection
    xmlto
  ];

  buildInputs = [
    glib
    libxml2
    libyaml
    xapian
  ];

  meta = with lib; {
    description = "Software metadata handling library";
    homepage = https://www.freedesktop.org/wiki/Distributions/AppStream/Software/;
    license = licenses.lgpl21Plus;
    maintainers = with maintainers; [ ];
    platforms = platforms.linux;
 };
}

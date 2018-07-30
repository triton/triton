{ stdenv
, combine-xml-catalogs
, docbook_xml_dtd_43
, docbook-xsl
, fetchurl
, gettext
, itstool
, lib
, libxml2
, libxslt

# TODO: reenable once texlive is fixed
#, dblatex
, python2
}:

let
  version = "1.28";

  xmlcatalog = combine-xml-catalogs [
    docbook-xsl
    docbook_xml_dtd_43
  ];
in
stdenv.mkDerivation rec {
  name = "gtk-doc-${version}";

  src = fetchurl {
    url = "mirror://gnome/sources/gtk-doc/${version}/${name}.tar.xz";
    hashOutput = false;
    sha256 = "911e29e302252c96128965ee1f4067d5431a88e00ad1023a8bc1d6b922af5715";
  };

  nativeBuildInputs = [
    gettext
    libxml2
    libxslt
    itstool
  ];

  buildInputs = [
    python2
  ];

  configureFlags = [
    "--with-xml-catalog=${xmlcatalog}"
  ];

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      sha256Url = "https://download.gnome.org/sources/gtk-doc/${version}/"
        + "${name}.sha256sum";
      failEarly = true;
    };
  };

  meta = with lib; {
    description = "Tools for documentation embedded in GTK+/GNOME source code";
    homepage = http://www.gtk.org/gtk-doc;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

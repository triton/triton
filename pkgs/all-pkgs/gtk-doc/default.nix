{ stdenv
, fetchurl
, which

, perl
, python
, libxml2
, libxslt
, docbook_xml_dtd_43
, docbook_xsl
, gnome_doc_utils
# TODO: reenable once texlive is fixed
#, dblatex
, gettext
, itstool
}:

stdenv.mkDerivation rec {
  name = "gtk-doc-${version}";
  version = "1.24";

  src = fetchurl {
    url = "mirror://gnome/sources/gtk-doc/${version}/${name}.tar.xz";
    sha256 = "12xmmcnq4138dlbhmqa45wqza8dky4lf856sp80h6xjwl2g7a85l";
  };

  preConfigure =
  /* maybe there is a better way to pass the needed dtd and xsl files
     "-//OASIS//DTD DocBook XML V4.1.2//EN" and
     "http://docbook.sourceforge.net/release/xsl/current/html/chunk.xsl" */ ''
    mkdir -pv $out/nix-support
    cat > $out/nix-support/catalog.xml << EOF
    <?xml version="1.0"?>
    <!DOCTYPE catalog PUBLIC "-//OASIS//DTD Entity Resolution XML Catalog V1.0//EN" "http://www.oasis-open.org/committees/entity/release/1.0/catalog.dtd">
    <catalog xmlns="urn:oasis:names:tc:entity:xmlns:xml:catalog">
      <nextCatalog  catalog="${docbook_xsl}/xml/xsl/docbook/catalog.xml" />
      <nextCatalog  catalog="${docbook_xml_dtd_43}/xml/dtd/docbook/catalog.xml" />
    </catalog>
    EOF

    configureFlagsArray+=(
      "--with-xml-catalog=$out/nix-support/catalog.xml"
      "--disable-scrollkeeper"
    )
  '';

  nativeBuildInputs = [
    which
  ];

  buildInputs = [
    perl
    python
    libxml2
    libxslt
    docbook_xml_dtd_43
    docbook_xsl
    gnome_doc_utils
    #dblatex
    gettext
    itstool
  ];

  meta = with stdenv.lib; {
    description = "Tools for documentation embedded in GTK+/GNOME source code";
    homepage = http://www.gtk.org/gtk-doc;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}

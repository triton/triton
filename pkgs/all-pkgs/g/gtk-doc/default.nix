{ stdenv
, fetchurl
, lib
, which

# TODO: reenable once texlive is fixed
#, dblatex
, docbook_xml_dtd_43
, docbook-xsl
, gettext
, glib
, gnome_doc_utils
, itstool
, libxml2
, libxslt
, perl
, python3Packages
}:

let
  version = "1.26";
in
stdenv.mkDerivation rec {
  name = "gtk-doc-${version}";

  src = fetchurl {
    url = "mirror://gnome/sources/gtk-doc/${version}/${name}.tar.xz";
    hashOutput = false;
    sha256 = "bff3f44467b1d39775e94fad545f050faa7e8d68dc6a31aef5024ba3c2d7f2b7";
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
      <nextCatalog  catalog="${docbook-xsl}/xml/xsl/docbook/catalog.xml" />
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
    #dblatex
    docbook_xml_dtd_43
    docbook-xsl
    gettext
    gnome_doc_utils
    itstool
    libxml2
    libxslt
    perl
    python3Packages.python
  ];

  propagatedBuildInputs = [
    glib
    python3Packages.six
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

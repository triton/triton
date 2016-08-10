{ stdenv
, fetchurl
, findXMLCatalogs
, flex
, makeWrapper

, getopt
, libxml2
}:

stdenv.mkDerivation rec {
  name = "xmlto-0.0.28";

  src = fetchurl {
    url = "https://fedorahosted.org/releases/x/m/xmlto/${name}.tar.bz2";
    multihash = "QmQddXXS6g9PUpw1Z5HDBHTX8gg7hcwKs3KYSWqXaUkMM2";
    sha256 = "0xhj8b2pwp4vhl9y16v3dpxpsakkflfamr191mprzsspg4xdyc0i";
  };

  buildInputs = [
    getopt
    libxml2
  ];

  # When using xmlto, it needs the ability to set the environment variables
  # for all of the XML Catalogs in the build inputs.
  propagatedBuildInputs = [
    findXMLCatalogs
  ];

  preConfigure = ''
    while read line; do
      eval $line
    done < <(./configure --help 2>&1 | awk '{ if (/[A-Z][ ]*Name/) { print "export " $1 "=\"$(type -P " tolower($1) ")\""; } }')
  '';

  meta = with stdenv.lib; {
    description = "Front-end to an XSL toolchain";
    homepage = https://fedorahosted.org/xmlto/;
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

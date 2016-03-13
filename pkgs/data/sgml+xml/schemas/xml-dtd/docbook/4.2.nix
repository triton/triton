{stdenv, fetchurl, unzip}:

import ./generic.nix {
  inherit stdenv fetchurl unzip;
  name = "docbook-xml-4.2";
  src = fetchurl {
    url = http://www.docbook.org/xml/4.2/docbook-xml-4.2.zip;
    sha256 = "18hgwvmywh6a5jh38szjmg3hg2r4v5lb6r3ydc3rd8cp9wg61i5c";
  };
  meta = {
    branch = "4.2";
  };
}

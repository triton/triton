{ stdenv, fetchurl, unzip }:

let 

  src = fetchurl {
    url = http://www.oasis-open.org/docbook/sgml/3.1/docbk31.zip;
    multihash = "QmfUY5gGjunL7MzA9n5Csn4wCj2FXUNaADF852bCCX6sxZ";
    sha256 = "0f25ch7bywwhdxb1qa0hl28mgq1blqdap3rxzamm585rf4kis9i0";
  };

  isoents = fetchurl {
    url = http://www.oasis-open.org/cover/ISOEnts.zip;
    multihash = "QmZZ1YvduSEzQFw6cjczYdv4UsdSTdhWgiTHjEhAARBSf6";
    sha256 = "1clrkaqnvc1ja4lj8blr0rdlphngkcda3snm7b9jzvcn76d3br6w";
  };

in

stdenv.mkDerivation {
  name = "docbook-sgml-3.1";

  unpackPhase = "true";

  buildInputs = [ unzip ];

  installPhase =
    ''
      o=$out/sgml/dtd/docbook-3.1
      mkdir -p $o
      cd $o
      unzip ${src}
      unzip ${isoents}
      sed -e "s/iso-/ISO/" -e "s/.gml//" -i docbook.cat
    '';
}

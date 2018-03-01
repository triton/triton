{ stdenv
, buildPythonPackage
, fetchurl
, isPy2
, lib
}:

buildPythonPackage rec {
  name = "PyXML-0.8.4";

  src = fetchurl {
    url = "mirror://sourceforge/pyxml/${name}.tar.gz";  # Dead
    multihash = "QmddnbskDskcAvi8NsELcw2QmiRtz1QUtfYjbtD9rLH1ad";
    sha256 = "9fab66f9584fb8e67aebd8745a5c97bf1c5a2e2e461adf68862bcec64e448c13";
  };

  disabled = !isPy2;

  meta = with lib; {
    description = "A collection of libraries to process XML with Python";
    homepage = http://pyxml.sourceforge.net/;
  };
}

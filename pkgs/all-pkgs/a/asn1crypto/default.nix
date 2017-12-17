{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "0.24.0";
in
buildPythonPackage rec {
  name = "asn1crypto-${version}";

  src = fetchPyPi {
    package = "asn1crypto";
    inherit version;
    sha256 = "9d5c20441baf0cb60a4ac34cc447c6c189024b6b4c6cd7877034f4965c464e49";
  };

  meta = with lib; {
    description = "Fast ASN.1 parser and serializer";
    homepage = https://github.com/wbond/asn1crypto;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

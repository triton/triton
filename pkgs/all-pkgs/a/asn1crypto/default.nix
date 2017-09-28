{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "0.23.0";
in
buildPythonPackage rec {
  name = "asn1crypto-${version}";

  src = fetchPyPi {
    package = "asn1crypto";
    inherit version;
    sha256 = "0874981329cfebb366d6584c3d16e913f2a0eb026c9463efcc4aaf42a9d94d70";
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

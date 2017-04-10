{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "0.22.0";
in
buildPythonPackage rec {
  name = "asn1crypto-${version}";

  src = fetchPyPi {
    package = "asn1crypto";
    inherit version;
    sha256 = "cbbadd640d3165ab24b06ef25d1dca09a3441611ac15f6a6b452474fdf0aed1a";
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

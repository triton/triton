{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, attrs
, ipaddress
, pyasn1
, pyasn1-modules
, pyopenssl
, pytest
}:

let
  inherit (lib)
    optionals;

  version = "18.1.0";
in
buildPythonPackage rec {
  name = "service_identity-${version}";

  src = fetchPyPi {
    package = "service_identity";
    inherit version;
    sha256 = "0858a54aabc5b459d1aafa8a518ed2081a285087f349fe3e55197989232e2e2d";
  };

  propagatedBuildInputs = [
    attrs
    ipaddress
    pyasn1
    pyasn1-modules
    pyopenssl
  ];

  meta = with lib; {
    description = "Service identity verification for pyOpenSSL";
    homepage = https://github.com/pyca/service_identity;
    license = licenses.bsd3;
    maintainers = with maintainers; [
      wkennington
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

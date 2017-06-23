{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, attrs
, pyasn1
, pyasn1-modules
, pyopenssl
, pytest
}:

let
  inherit (lib)
    optionals;

  version = "17.0.0";
in
buildPythonPackage rec {
  name = "service_identity-${version}";

  src = fetchPyPi {
    package = "service_identity";
    inherit version;
    sha256 = "4001fbb3da19e0df22c47a06d29681a398473af4aa9d745eca525b3b2c2302ab";
  };

  propagatedBuildInputs = [
    attrs
    pyasn1
    pyasn1-modules
    pyopenssl
  ];

  buildInputs = optionals doCheck [
    pytest
  ];

  doCheck = true;

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

{ stdenv
, buildPythonPackage
, fetchPyPi

, attrs
, pyasn1-modules
, pyopenssl
, pytest
}:

let
  inherit (stdenv.lib)
    optionals;

  version = "16.0.0";
in
buildPythonPackage rec {
  name = "service_identity-${version}";

  src = fetchPyPi {
    package = "service_identity";
    inherit version;
    sha256 = "0630e222f59f91f3db498be46b1d879ff220955d7bbad719a5cb9ad14e3c3036";
  };

  propagatedBuildInputs = [
    attrs
    pyasn1-modules
    pyopenssl
  ];

  buildInputs = optionals doCheck [
    pytest
  ];

  doCheck = true;

  meta = with stdenv.lib; {
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

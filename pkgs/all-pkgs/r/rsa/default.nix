{ stdenv
, buildPythonPackage
, fetchPyPi

, pyasn1
}:

let
  version = "3.4.2";
in
buildPythonPackage rec {
  name = "rsa-${version}";

  src = fetchPyPi {
    package = "rsa";
    inherit version;
    sha256 = "25df4e10c263fb88b5ace923dd84bf9aa7f5019687b5e55382ffcdb8bede9db5";
  };

  propagatedBuildInputs = [
    pyasn1
  ];

  meta = with stdenv.lib; {
    description = "Pure-Python RSA implementation";
    homepage = https://stuvel.eu/rsa;
    license = licenses.asl20;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

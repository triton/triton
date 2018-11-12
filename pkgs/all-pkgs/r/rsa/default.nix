{ stdenv
, buildPythonPackage
, fetchPyPi

, pyasn1
}:

let
  version = "4.0";
in
buildPythonPackage rec {
  name = "rsa-${version}";

  src = fetchPyPi {
    package = "rsa";
    inherit version;
    sha256 = "1a836406405730121ae9823e19c6e806c62bbad73f890574fff50efa4122c487";
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

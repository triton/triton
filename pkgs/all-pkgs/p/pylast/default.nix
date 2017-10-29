{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, six
}:

let
  version = "2.0.0";
in
buildPythonPackage rec {
  name = "pylast-${version}";

  src = fetchPyPi {
    package = "pylast";
    inherit version;
    sha256 = "8e4d4962aa12d67bd357e1aa596a146b2e97afd943b5c9257e555014d13b3065";
  };

  propagatedBuildInputs = [
    six
  ];

  meta = with lib; {
    description = "A Python interface to Last.fm and Libre.fm";
    homepage = https://github.com/pylast/pylast;
    license = licenses.asl20;
    maintainers = with maintainers; [ ];
    platforms = with platforms;
      x86_64-linux;
  };
}

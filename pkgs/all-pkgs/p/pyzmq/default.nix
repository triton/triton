{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, zeromq
}:

let
  version = "16.0.2";
in
buildPythonPackage rec {
  name = "pyzmq-${version}";

  src = fetchPyPi {
    package = "pyzmq";
    inherit version;
    sha256 = "0322543fff5ab6f87d11a8a099c4c07dd8a1719040084b6ce9162bcdf5c45c9d";
  };

  propagatedBuildInputs = [
    zeromq
  ];

  meta = with lib; {
    description = "Python binding for the ZeroMQ Messaging Library";
    homepage = https://pyzmq.readthedocs.org/;
    license = licenses.bsd3;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

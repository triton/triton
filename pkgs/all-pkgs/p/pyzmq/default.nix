{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, zeromq
}:

let
  version = "16.0.3";
in
buildPythonPackage rec {
  name = "pyzmq-${version}";

  src = fetchPyPi {
    package = "pyzmq";
    inherit version;
    sha256 = "8a883824147523c0fe76d247dd58994c1c28ef07f1cc5dde595a4fd1c28f2580";
  };

  buildInputs = [
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

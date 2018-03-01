{ stdenv
, buildPythonPackage
, cython
, fetchPyPi
, lib

, zeromq
}:

let
  version = "17.0.0";
in
buildPythonPackage rec {
  name = "pyzmq-${version}";

  src = fetchPyPi {
    package = "pyzmq";
    inherit version;
    sha256 = "0145ae59139b41f65e047a3a9ed11bbc36e37d5e96c64382fcdff911c4d8c3f0";
  };

  nativeBuildInputs = [
    cython
  ];

  buildInputs = [
    zeromq
  ];

  preBuild = /* Force cython files to be regenerated */ ''
    rm zmq/backend/cython/*.c \
      zmq/devices/*.c
  '';

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

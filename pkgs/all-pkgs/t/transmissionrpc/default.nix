{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, six
}:

let
  version = "0.11";
in
buildPythonPackage rec {
  name = "transmissionrpc-${version}";

  src = fetchPyPi {
    package = "transmissionrpc";
    inherit version;
    sha256 = "ec43b460f9fde2faedbfa6d663ef495b3fd69df855a135eebe8f8a741c0dde60";
  };

  buildInputs = [
    six
  ];

  doCheck = true;

  meta = with lib; {
    description = "Transmission bittorent client RPC protocol";
    homepage = https://pypi.python.org/pypi/transmissionrpc/;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

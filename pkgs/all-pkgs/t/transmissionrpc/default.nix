{ stdenv
, buildPythonPackage
, fetchPyPi

, pythonPackages
}:

buildPythonPackage rec {
  name = "transmissionrpc-${version}";
  version = "0.11";

  src = fetchPyPi {
    package = "transmissionrpc";
    inherit version;
    sha256 = "ec43b460f9fde2faedbfa6d663ef495b3fd69df855a135eebe8f8a741c0dde60";
  };

  buildInputs = [
    pythonPackages.six
  ];

  doCheck = true;

  meta = with stdenv.lib; {
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

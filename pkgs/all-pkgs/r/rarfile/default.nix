{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, cryptography
}:

let
  version = "3.0";
in
buildPythonPackage rec {
  name = "rarfile-${version}";

  src = fetchPyPi {
    package = "rarfile";
    inherit version;
    sha256 = "e816409e3b36794507cbe0b678bed3e4703d7412c5f7f9201a510ed6fdc66c35";
  };

  propagatedBuildInputs = [
    cryptography
    #datetime
    #hashlib
    #pyblake2
  ];

  meta = with lib; {
    description = "RAR archive reader for Python";
    homepage = https://github.com/markokr/rarfile;
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    platforms = with platforms;
      x86_64-linux;
  };
}

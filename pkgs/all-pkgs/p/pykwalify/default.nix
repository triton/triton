{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, docopt
, python-dateutil
, pyyaml
}:

let
  version = "1.7.0";
in
buildPythonPackage {
  name = "pykwalify-${version}";

  src = fetchPyPi {
    package = "pykwalify";
    inherit version;
    sha256 = "7e8b39c5a3a10bc176682b3bd9a7422c39ca247482df198b402e8015defcceb2";
  };

  propagatedBuildInputs = [
    docopt
    python-dateutil
    pyyaml
  ];

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, docopt
, python-dateutil
, pyyaml
}:

let
  version = "1.6.0";
in
buildPythonPackage {
  name = "pykwalify-${version}";

  src = fetchPyPi {
    package = "pykwalify";
    inherit version;
    sha256 = "2298fafe84dc68161835f62a1b8d0d72dd749d5742baa196224882a6ac2ff844";
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

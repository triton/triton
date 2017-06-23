{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, docutils
, mistune
}:

let
  version = "0.1.6";
in
buildPythonPackage {
  name = "m2r-${version}";

  src = fetchPyPi {
    package = "m2r";
    inherit version;
    sha256 = "a26bc2e25e0ad3f8650385aea25cf734ac4fcd30e54faec92fd39675da75e527";
  };

  buildInputs = [
    docutils
  ];

  propagatedBuildInputs = [
    mistune
  ];

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

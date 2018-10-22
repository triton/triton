{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, docutils
, mistune
}:

let
  version = "0.2.1";
in
buildPythonPackage {
  name = "m2r-${version}";

  src = fetchPyPi {
    package = "m2r";
    inherit version;
    sha256 = "bf90bad66cda1164b17e5ba4a037806d2443f2a4d5ddc9f6a5554a0322aaed99";
  };

  propagatedBuildInputs = [
    docutils
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

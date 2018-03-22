{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, docutils
, mistune
}:

let
  version = "0.1.14";
in
buildPythonPackage {
  name = "m2r-${version}";

  src = fetchPyPi {
    package = "m2r";
    inherit version;
    sha256 = "a14635cdeedb125f0f85e014eb5898fd634e2da358a160c124818e9c9f851add";
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

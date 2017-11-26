{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, docutils
, mistune
}:

let
  version = "0.1.12";
in
buildPythonPackage {
  name = "m2r-${version}";

  src = fetchPyPi {
    package = "m2r";
    inherit version;
    sha256 = "adfb86ebb7ff3fcd3ebb27ce8cd6f795c409a13f0c03363e265f17419ce5b9ab";
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

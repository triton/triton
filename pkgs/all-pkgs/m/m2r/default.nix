{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, docutils
, mistune
}:

let
  version = "0.1.13";
in
buildPythonPackage {
  name = "m2r-${version}";

  src = fetchPyPi {
    package = "m2r";
    inherit version;
    sha256 = "b19e3703a3a897859f01ff6a068ee9a0eea8e8fdf75e896e00e88b3476a12f87";
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

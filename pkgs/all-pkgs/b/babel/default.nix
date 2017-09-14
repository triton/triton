{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, pytz
}:

let
  version = "2.5.1";
in
buildPythonPackage {
  name = "Babel-${version}";

  src = fetchPyPi {
    package = "Babel";
    inherit version;
    sha256 = "6007daf714d0cd5524bbe436e2d42b3c20e68da66289559341e48d2cd6d25811";
  };

  propagatedBuildInputs = [
    pytz
  ];

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

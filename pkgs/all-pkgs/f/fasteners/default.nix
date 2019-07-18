{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, monotonic
, six
}:

let
  version = "0.15";
in
buildPythonPackage {
  name = "fasteners-${version}";

  src = fetchPyPi {
    package = "fasteners";
    inherit version;
    sha256 = "3a176da6b70df9bb88498e1a18a9e4a8579ed5b9141207762368a1017bf8f5ef";
  };

  propagatedBuildInputs = [
    monotonic
    six
  ];

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

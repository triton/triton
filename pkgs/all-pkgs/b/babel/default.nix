{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, pytz
}:

let
  version = "2.4.0";
in
buildPythonPackage {
  name = "Babel-${version}";

  src = fetchPyPi {
    package = "Babel";
    inherit version;
    sha256 = "8c98f5e5f8f5f088571f2c6bd88d530e331cbbcb95a7311a0db69d3dca7ec563";
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

{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, html5lib
, six
}:

let
  version = "3.1.0";
in
buildPythonPackage {
  name = "bleach-${version}";

  src = fetchPyPi {
    package = "bleach";
    inherit version;
    sha256 = "3fdf7f77adcf649c9911387df51254b813185e32b2c6619f690b593a617e19fa";
  };

  propagatedBuildInputs = [
    html5lib
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

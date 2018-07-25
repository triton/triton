{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, pytz
}:

let
  version = "2.6.0";
in
buildPythonPackage {
  name = "Babel-${version}";

  src = fetchPyPi {
    package = "Babel";
    inherit version;
    sha256 = "8cba50f48c529ca3fa18cf81fa9403be176d374ac4d60738b839122dfaaa3d23";
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

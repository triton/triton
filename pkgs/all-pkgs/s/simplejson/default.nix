{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "3.14.0";
in
buildPythonPackage {
  name = "simplejson-${version}";

  src = fetchPyPi {
    package = "simplejson";
    inherit version;
    sha256 = "1ebbd84c2d7512f7ba65df0b9cc3cbc1bbd6ef9eab39fc9389dfe7e3681f7bd2";
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

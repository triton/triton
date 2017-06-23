{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "3.11.1";
in
buildPythonPackage {
  name = "simplejson-${version}";

  src = fetchPyPi {
    package = "simplejson";
    inherit version;
    sha256 = "01a22d49ddd9a168b136f26cac87d9a335660ce07aa5c630b8e3607d6f4325e7";
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

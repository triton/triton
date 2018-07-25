{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "0.7.11";
in
buildPythonPackage {
  name = "alabaster-${version}";

  src = fetchPyPi {
    package = "alabaster";
    inherit version;
    sha256 = "b63b1f4dc77c074d386752ec4a8a7517600f6c0db8cd42980cae17ab7b3275d7";
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

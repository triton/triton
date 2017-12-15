{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "8.8.8";
in
buildPythonPackage {
  name = "phonenumbers-${version}";

  src = fetchPyPi {
    package = "phonenumbers";
    inherit version;
    sha256 = "ff2f492e49c212bb7185954efe09e68583a67daec586c02c49bc728c343d4eb0";
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

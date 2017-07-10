{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "8.6.0";
in
buildPythonPackage {
  name = "phonenumbers-${version}";

  src = fetchPyPi {
    package = "phonenumbers";
    inherit version;
    sha256 = "8078c524f6ba8172ca045b10c5b872c2489226338652c200637169cce25e8b7c";
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

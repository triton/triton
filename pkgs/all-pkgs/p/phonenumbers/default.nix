{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "8.7.0";
in
buildPythonPackage {
  name = "phonenumbers-${version}";

  src = fetchPyPi {
    package = "phonenumbers";
    inherit version;
    sha256 = "af6cddb5150ced7944e137075892a6f80f637a0b283863c368e73ad302cb3cfa";
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

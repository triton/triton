{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "8.5.1";
in
buildPythonPackage {
  name = "phonenumbers-${version}";

  src = fetchPyPi {
    package = "phonenumbers";
    inherit version;
    sha256 = "b7d1a5832650fad633d1e4159873788ebfb15e053292c20ab9f5119a574f3a67";
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

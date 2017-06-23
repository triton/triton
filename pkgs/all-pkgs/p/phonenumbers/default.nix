{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "8.5.2";
in
buildPythonPackage {
  name = "phonenumbers-${version}";

  src = fetchPyPi {
    package = "phonenumbers";
    inherit version;
    sha256 = "aff33117e0a285ad0e116d29b492f2e0f360eef16236ee12cf26d673eafb3fbe";
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

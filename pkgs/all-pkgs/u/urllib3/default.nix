{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "1.21.1";
in
buildPythonPackage {
  name = "urllib3-${version}";

  src = fetchPyPi {
    package = "urllib3";
    inherit version;
    sha256 = "b14486978518ca0901a76ba973d7821047409d7f726f22156b24e83fd71382a5";
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

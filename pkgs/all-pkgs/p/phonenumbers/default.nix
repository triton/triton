{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "8.9.6";
in
buildPythonPackage {
  name = "phonenumbers-${version}";

  src = fetchPyPi {
    package = "phonenumbers";
    inherit version;
    sha256 = "eec334a7908746b675a0ba296b3a11322ed970614b62f2a6e5f086de4f3e2a84";
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

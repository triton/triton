{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "8.8.11";
in
buildPythonPackage {
  name = "phonenumbers-${version}";

  src = fetchPyPi {
    package = "phonenumbers";
    inherit version;
    sha256 = "ffe202e576921c8206dc4559dac4d40087a9e84cf375e59a44b115a7f20ad3fb";
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

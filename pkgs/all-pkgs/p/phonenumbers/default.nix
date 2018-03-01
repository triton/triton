{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "8.9.0";
in
buildPythonPackage {
  name = "phonenumbers-${version}";

  src = fetchPyPi {
    package = "phonenumbers";
    inherit version;
    sha256 = "2cb4822ba895200b06f46a788e852d6ae8200fdc97e1d7c86b0ee10c99d4ff3a";
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

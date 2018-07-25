{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "1.23";
in
buildPythonPackage {
  name = "urllib3-${version}";

  src = fetchPyPi {
    package = "urllib3";
    inherit version;
    sha256 = "a68ac5e15e76e7e5dd2b8f94007233e01effe3e50e8daddf69acfd81cb686baf";
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

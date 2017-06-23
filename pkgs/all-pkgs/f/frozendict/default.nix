{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "1.2";
in
buildPythonPackage {
  name = "frozendict-${version}";

  src = fetchPyPi {
    package = "frozendict";
    inherit version;
    sha256 = "774179f22db2ef8a106e9c38d4d1f8503864603db08de2e33be5b778230f6e45";
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

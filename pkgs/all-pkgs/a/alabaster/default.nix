{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "0.7.10";
in
buildPythonPackage {
  name = "alabaster-${version}";

  src = fetchPyPi {
    package = "alabaster";
    inherit version;
    sha256 = "37cdcb9e9954ed60912ebc1ca12a9d12178c26637abdf124e3cde2341c257fe0";
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

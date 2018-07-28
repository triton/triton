{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "3.6.4";
in
buildPythonPackage {
  name = "pycryptodomex-${version}";

  src = fetchPyPi {
    package = "pycryptodomex";
    inherit version;
    sha256 = "4daabe7c0404e673b9029aa43761c779b9b4df2cbe11ccd94daded6a0acd8808";
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

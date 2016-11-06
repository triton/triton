{ stdenv
, buildPythonPackage
, fetchPyPi
}:

let
  version = "1.5.3";
in
buildPythonPackage {
  name = "cryptography_vectors-${version}";

  src = fetchPyPi {
    package = "cryptography_vectors";
    inherit version;
    sha256 = "e513fecd146a844da19022abd1b4dfbf3335c1941464988f501d7a16f30acdae";
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

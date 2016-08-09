{ stdenv
, buildPythonPackage
, fetchPyPi
}:

let
  version = "4.0.10";
in
buildPythonPackage {
  name = "decorator-${version}";

  src = fetchPyPi {
    package = "decorator";
    inherit version;
    sha256 = "9c6e98edcb33499881b86ede07d9968c81ab7c769e28e9af24075f0a5379f070";
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

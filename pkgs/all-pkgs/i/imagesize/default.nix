{ stdenv
, buildPythonPackage
, fetchPyPi
}:

let
  version = "1.0.0";
in
buildPythonPackage {
  name = "imagesize-${version}";

  src = fetchPyPi {
    package = "imagesize";
    inherit version;
    sha256 = "5b326e4678b6925158ccc66a9fa3122b6106d7c876ee32d7de6ce59385b96315";
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

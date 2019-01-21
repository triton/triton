{ stdenv
, buildPythonPackage
, fetchPyPi
}:

let
  version = "1.1.0";
in
buildPythonPackage {
  name = "imagesize-${version}";

  src = fetchPyPi {
    package = "imagesize";
    inherit version;
    sha256 = "f3832918bc3c66617f92e35f5d70729187676313caa60c187eb0f28b8fe5e3b5";
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

{ stdenv
, buildPythonPackage
, fetchPyPi
}:

let
  version = "15.1.0";
in
buildPythonPackage rec {
  name = "constantly-${version}";

  src = fetchPyPi {
    package = "constantly";
    inherit version;
    sha256 = "586372eb92059873e29eba4f9dec8381541b4d3834660707faf8ba59146dfc35";
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

{ stdenv
, buildPythonPackage
, fetchPyPi
}:

let
  version = "0.17.1";
in
buildPythonPackage {
  name = "future-${version}";

  src = fetchPyPi {
    package = "future";
    inherit version;
    sha256 = "67045236dcfd6816dc439556d009594abf643e5eb48992e36beac09c2ca659b8";
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "0.3.3";
in
buildPythonPackage {
  name = "pyasn1-${version}";

  src = fetchPyPi {
    package = "pyasn1";
    inherit version;
    sha256 = "01c20ade412088b42dcd5f0fef6149f6b7377297c5c5f222bb5ef0331ee3517c";
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

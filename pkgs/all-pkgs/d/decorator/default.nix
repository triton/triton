{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "4.0.11";
in
buildPythonPackage {
  name = "decorator-${version}";

  src = fetchPyPi {
    package = "decorator";
    inherit version;
    sha256 = "953d6bf082b100f43229cf547f4f97f97e970f5ad645ee7601d55ff87afdfe76";
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

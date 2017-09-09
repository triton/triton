{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "0.3.4";
in
buildPythonPackage {
  name = "pyasn1-${version}";

  src = fetchPyPi {
    package = "pyasn1";
    inherit version;
    sha256 = "3946ff0ab406652240697013a89d76e388344866033864ef2b097228d1f0101a";
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

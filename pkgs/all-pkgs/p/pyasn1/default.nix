{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "0.4.5";
in
buildPythonPackage {
  name = "pyasn1-${version}";

  src = fetchPyPi {
    package = "pyasn1";
    inherit version;
    sha256 = "da2420fe13a9452d8ae97a0e478adde1dee153b11ba832a95b223a2ba01c10f7";
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "2.5";
in
buildPythonPackage {
  name = "cryptography-vectors-${version}";

  src = fetchPyPi {
    package = "cryptography_vectors";
    inherit version;
    sha256 = "333649b96300ddf2edaddda1adb407665de34ca11c7ef0410ec1096eefa00e97";
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

{ stdenv
, buildPythonPackage
, fetchPyPi
}:

let
  version = "1.6";
in
buildPythonPackage {
  name = "cryptography_vectors-${version}";

  src = fetchPyPi {
    package = "cryptography_vectors";
    inherit version;
    sha256 = "01ccb07c95d128a70732f274bd16af479bcc344e43cac745d2b9ec4ab71ff675";
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

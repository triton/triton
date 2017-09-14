{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "0.7.2";
in
buildPythonPackage {
  name = "prettytable-${version}";

  src = fetchPyPi {
    package = "prettytable";
    inherit version;
    sha256 = "2d5460dc9db74a32bcc8f9f67de68b2c4f4d2f01fa3bd518764c69156d9cacd9";
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

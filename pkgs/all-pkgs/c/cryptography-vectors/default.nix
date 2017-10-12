{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "2.1.1";
in
buildPythonPackage {
  name = "cryptography_vectors-${version}";

  src = fetchPyPi {
    package = "cryptography_vectors";
    inherit version;
    sha256 = "92f1300dd2b0a5812ca5d28003b7a11eb9eadba8c1c8c2b5150a0132d4a1fd64";
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "2.0";
in
buildPythonPackage {
  name = "cryptography_vectors-${version}";

  src = fetchPyPi {
    package = "cryptography_vectors";
    inherit version;
    sha256 = "f03099e00179824b6ba54096da71fe13812bc08dddc50c3c2ff3841280f64d61";
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

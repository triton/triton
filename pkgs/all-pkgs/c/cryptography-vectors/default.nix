{ stdenv
, buildPythonPackage
, fetchPyPi
}:

let
  version = "1.5.1";
in
buildPythonPackage {
  name = "cryptography_vectors-${version}";

  src = fetchPyPi {
    package = "cryptography_vectors";
    inherit version;
    sha256 = "94b1c5311b7d70660bff2451a8cf99c1af0731bcd4d11e96f99df64d39aee4fc";
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

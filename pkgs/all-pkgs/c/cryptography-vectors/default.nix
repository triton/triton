{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "1.8.1";
in
buildPythonPackage {
  name = "cryptography_vectors-${version}";

  src = fetchPyPi {
    package = "cryptography_vectors";
    inherit version;
    sha256 = "2fd61facea08800ca98ac923f6d02f48a7ae6648025b29cdeb51987c1532add6";
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

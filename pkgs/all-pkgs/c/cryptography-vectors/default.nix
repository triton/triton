{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "1.7.2";
in
buildPythonPackage {
  name = "cryptography_vectors-${version}";

  src = fetchPyPi {
    package = "cryptography_vectors";
    inherit version;
    sha256 = "4be4eee8a11deee5c2f00e389b49de8ce2642130282d1cd0adffb2f7dbe0acdc";
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

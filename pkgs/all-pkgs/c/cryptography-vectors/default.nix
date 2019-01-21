{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "2.4.2";
in
buildPythonPackage {
  name = "cryptography-vectors-${version}";

  src = fetchPyPi {
    package = "cryptography_vectors";
    inherit version;
    sha256 = "91d365350a2d9d5376e4efdba687c7258e31a7c8c0deefbe4f674bf0a1e87804";
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

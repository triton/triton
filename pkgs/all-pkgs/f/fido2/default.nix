{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "0.7.0";
in
buildPythonPackage {
  name = "fido2-${version}";

  src = fetchPyPi {
    package = "fido2";
    inherit version;
    sha256 = "47b02852780849bb4bb698b9727d61970ee77a83eb25715fe7c6235ebd648d87";
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

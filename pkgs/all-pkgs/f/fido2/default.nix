{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "0.3.0";
in
buildPythonPackage {
  name = "fido2-${version}";

  src = fetchPyPi {
    package = "fido2";
    inherit version;
    sha256 = "32c0db375458853d68cbbeb04861c412a05c22c873236a0c4f71296dc983ab35";
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

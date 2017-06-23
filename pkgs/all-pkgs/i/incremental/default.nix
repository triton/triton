{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "17.5.0";
in
buildPythonPackage rec {
  name = "incremental-${version}";

  src = fetchPyPi {
    package = "incremental";
    inherit version;
    sha256 = "7b751696aaf36eebfab537e458929e194460051ccad279c72b755a167eebd4b3";
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

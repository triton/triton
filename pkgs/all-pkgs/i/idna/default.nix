{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "2.7";
in
buildPythonPackage {
  name = "idna-${version}";

  src = fetchPyPi {
    package = "idna";
    inherit version;
    sha256 = "684a38a6f903c1d71d6d5fac066b58d7768af4de2b832e426ec79c30daa94a16";
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

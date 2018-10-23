{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "1.24";
in
buildPythonPackage {
  name = "urllib3-${version}";

  src = fetchPyPi {
    package = "urllib3";
    inherit version;
    sha256 = "41c3db2fc01e5b907288010dec72f9d0a74e37d6994e6eb56849f59fea2265ae";
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

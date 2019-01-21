{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, pykwalify
, ruamel-yaml
}:

let
  version = "1.2.14";
in
buildPythonPackage {
  name = "borgmatic-${version}";

  src = fetchPyPi {
    package = "borgmatic";
    inherit version;
    sha256 = "1a6ad21e2db8cce7a1191e6a911120c516eba4721e584389df751583974c1e65";
  };

  propagatedBuildInputs = [
    pykwalify
    ruamel-yaml
  ];

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

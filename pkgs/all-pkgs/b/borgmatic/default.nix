{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, pykwalify
, ruamel-yaml
}:

let
  version = "1.2.9";
in
buildPythonPackage {
  name = "borgmatic-${version}";

  src = fetchPyPi {
    package = "borgmatic";
    inherit version;
    sha256 = "37390bd684eb67a03c54565469153942f4b2e4fd83a250dea80222531960f9c0";
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

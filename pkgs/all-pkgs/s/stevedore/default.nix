{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, pbr
, six
}:

let
  version = "1.27.1";
in
buildPythonPackage {
  name = "stevedore-${version}";

  src = fetchPyPi {
    package = "stevedore";
    inherit version;
    sha256 = "236468dae36707069e8b3bdb455e9f1be090b1e6b937f4ac0c56a538d6f50be0";
  };

  propagatedBuildInputs = [
    pbr
    six
  ];

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

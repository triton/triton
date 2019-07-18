{ stdenv
, buildPythonPackage
, fetchPyPi
, isPy2
, lib
, pbr

, funcsigs
, six
, wrapt
}:

let
  version = "1.21.0";
in
buildPythonPackage {
  name = "debtcollector-${version}";

  src = fetchPyPi {
    package = "debtcollector";
    inherit version;
    sha256 = "f6ce5a383ad73c23e1138dbb69bf45d33f4a4bdec38f02dbf2b89477ec5e55bc";
  };

  propagatedBuildInputs = [
    pbr
    six
    wrapt
  ] ++ lib.optionals isPy2 [
    funcsigs
  ];

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

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
    sha256 = "1f751d74789baa82684f55bececf754ebff1ad40e3fb1bee44fcf5c25a31e92d";
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

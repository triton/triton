{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, plumbum

, nose
}:

let
  inherit (lib)
    optionals;

  version = "3.4.2";
in
buildPythonPackage rec {
  name = "rpyc-${version}";

  src = fetchPyPi {
    package = "rpyc";
    inherit version;
    sha256 = "65862f275894dd933bb64b81c250acd7e000ce9439a323c1f8b0de2259782ae5";
  };

  propagatedBuildInputs = [
    plumbum
  ] ++ optionals doCheck [
    nose
  ];

  doCheck = true;

  meta = with lib; {
    description = "A transparent and symmetric RPC library";
    homepage = http://rpyc.readthedocs.org;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

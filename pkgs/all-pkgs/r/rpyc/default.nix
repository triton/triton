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

  version = "3.4.4";
in
buildPythonPackage rec {
  name = "rpyc-${version}";

  src = fetchPyPi {
    package = "rpyc";
    inherit version;
    sha256 = "a8991d0412a67d7299d105b4889b2b0b0d18e9b99404ea14eea56404fdb481c7";
  };

  propagatedBuildInputs = [
    plumbum
  ] ++ optionals doCheck [
    nose
  ];

  doCheck = false;  # FIXME: re-enable for >3.4.4

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

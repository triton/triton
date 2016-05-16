{ stdenv
, buildPythonPackage
, fetchPyPi

, pythonPackages
}:

let
  inherit (stdenv.lib)
    optionals;
in

buildPythonPackage rec {
  name = "rpyc-${version}";
  version = "3.3.0";

  src = fetchPyPi {
    package = "rpyc";
    inherit version;
    sha256 = "43fa845314f0bf442f5f5fab15bb1d1b5fe2011a8fc603f92d8022575cef8b4b";
  };

  propagatedBuildInputs = [
    pythonPackages.plumbum
  ] ++ optionals doCheck [
    pythonPackages.nose
  ];

  doCheck = true;

  meta = with stdenv.lib; {
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

{ stdenv
, buildPythonPackage
, fetchPyPi
, isPy2
, lib
, python

, zope-event
}:

let
  inherit (lib)
    optionals;

  version = "4.6.0";
in
buildPythonPackage rec {
  name = "zope.interface-${version}";

  src = fetchPyPi {
    package = "zope.interface";
    inherit version;
    sha256 = "1b3d0dcabc7c90b470e59e38a9acaa361be43b3a6ea644c0063951964717f0e5";
  };

  nativeBuildInputs = optionals doCheck [
    zope-event
  ];

  doCheck = true;

  meta = with lib; {
    description = "Interfaces for Python";
    homepage = http://zope.org/Products/ZopeInterface;
    license = licenses.zpt20;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

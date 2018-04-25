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

  version = "4.5.0";
in
buildPythonPackage rec {
  name = "zope.interface-${version}";

  src = fetchPyPi {
    package = "zope.interface";
    inherit version;
    sha256 = "57c38470d9f57e37afb460c399eb254e7193ac7fb8042bd09bdc001981a9c74c";
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

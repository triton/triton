{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, zope-event
}:

let
  version = "4.4.1";
in
buildPythonPackage rec {
  name = "zope.interface-${version}";

  src = fetchPyPi {
    package = "zope.interface";
    inherit version;
    sha256 = "350e3615d70a96678c3170eb5c96d4f72b8e7738861afbf030967d52c05722fe";
  };

  buildInputs = [
    zope-event
  ];

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

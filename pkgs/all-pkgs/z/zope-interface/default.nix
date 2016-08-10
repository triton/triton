{ stdenv
, buildPythonPackage
, fetchPyPi

, zope-event
}:

let
  version = "4.2.0";
in
buildPythonPackage rec {
  name = "zope.interface-${version}";

  src = fetchPyPi {
    package = "zope.interface";
    inherit version;
    sha256 = "36762743940a075283e1fb22a2ec9e8231871dace2aa00599511ddc4edf0f8f9";
  };

  buildInputs = [
    zope-event
  ];

  meta = with stdenv.lib; {
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

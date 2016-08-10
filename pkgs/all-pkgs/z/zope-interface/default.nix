{ stdenv
, buildPythonPackage
, fetchPyPi

, pythonPackages
}:

buildPythonPackage rec {
  name = "zope.interface-${version}";
  version = "4.2.0";

  src = fetchPyPi {
    package = "zope.interface";
    inherit version;
    sha256 = "36762743940a075283e1fb22a2ec9e8231871dace2aa00599511ddc4edf0f8f9";
  };

  buildInputs = [
    pythonPackages.zope-event
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

{ stdenv
, buildPythonPackage
, fetchPyPi

, pythonPackages
}:

buildPythonPackage rec {
  name = "zope.interface-${version}";
  version = "4.1.3";

  src = fetchPyPi {
    package = "zope.interface";
    inherit version;
    sha256 = "2e221a9eec7ccc58889a278ea13dcfed5ef939d80b07819a9a8b3cb1c681484f";
  };

  buildInputs = [
    pythonPackages.zope-event
  ];

  doCheck = true;

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

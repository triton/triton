{ stdenv
, buildPythonPackage
, fetchurl

, pythonPackages
}:

buildPythonPackage rec {
  name = "zope.interface-4.1.3";

  src = fetchurl {
    url = "mirror://pypi/z/zope.interface/${name}.tar.gz";
    sha256 = "2e221a9eec7ccc58889a278ea13dcfed5ef939d80b07819a9a8b3cb1c681484f";
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

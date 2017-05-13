{ stdenv
, buildPythonPackage
, fetchPyPi

, zope-event
}:

let
  version = "4.4.0";
in
buildPythonPackage rec {
  name = "zope.interface-${version}";

  src = fetchPyPi {
    package = "zope.interface";
    inherit version;
    sha256 = "e50e5e87cde9bf0ed59229fd372390c2d68b3674ae313858ef544d32051e2cd3";
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

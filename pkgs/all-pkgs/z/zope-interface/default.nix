{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, zope-event
}:

let
  version = "4.4.2";
in
buildPythonPackage rec {
  name = "zope.interface-${version}";

  src = fetchPyPi {
    package = "zope.interface";
    inherit version;
    sha256 = "4e59e427200201f69ef82956ddf9e527891becf5b7cde8ec3ce39e1d0e262eb0";
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

{ stdenv
, buildPythonPackage
, fetchPyPi

, zope-event
}:

let
  version = "4.3.1";
in
buildPythonPackage rec {
  name = "zope.interface-${version}";

  src = fetchPyPi {
    package = "zope.interface";
    inherit version;
    sha256 = "320920cedb07666fd4022f6a0fcd4a44551133a8415c98eac0873b753bb5a70c";
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

{ stdenv
, buildPythonPackage
, fetchPyPi

, pythonPackages
}:

buildPythonPackage rec {
  name = "zope-component-${version}";
  version = "4.2.2";

  src = fetchPyPi {
    package = "zope.component";
    inherit version;
    sha256 = "282c112b55dd8e3c869a3571f86767c150ab1284a9ace2bdec226c592acaf81a";
  };

  propagatedBuildInputs = [
    pythonPackages.zope-event
    pythonPackages.zope-interface
  ];

  meta = with stdenv.lib; {
    description = "Zope Component Architecture";
    homepage = https://github.com/zopefoundation/zope.component;
    license = licenses.free; # zope pl
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

{ stdenv
, buildPythonPackage
, fetchPyPi

, zope-event
, zope-interface
}:

let
  version = "4.2.2";
in
buildPythonPackage rec {
  name = "zope-component-${version}";

  src = fetchPyPi {
    package = "zope.component";
    inherit version;
    sha256 = "282c112b55dd8e3c869a3571f86767c150ab1284a9ace2bdec226c592acaf81a";
  };

  propagatedBuildInputs = [
    zope-event
    zope-interface
  ];

  meta = with stdenv.lib; {
    description = "Zope Component Architecture";
    homepage = https://github.com/zopefoundation/zope.component;
    license = licenses.zpt20;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

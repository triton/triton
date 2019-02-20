{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, cheroot
, jaraco-classes
, portend
, setuptools-scm
, six
}:

let
  version = "18.1.0";
in
buildPythonPackage rec {
  name = "cherrypy-${version}";

  src = fetchPyPi {
    package = "CherryPy";
    inherit version;
    sha256 = "4dd2f59b5af93bd9ca85f1ed0bb8295cd0f5a8ee2b84d476374d4e070aa5c615";
  };

  propagatedBuildInputs = [
    cheroot
    jaraco-classes
    portend
    setuptools-scm
    six
  ];

  doCheck = false;

  meta = with lib; {
    description = "A pythonic, object-oriented HTTP framework";
    homepage = http://www.cherrypy.org;
    license = licenses.bsd3;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

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
  version = "17.0.0";
in
buildPythonPackage rec {
  name = "cherrypy-${version}";

  src = fetchPyPi {
    package = "CherryPy";
    inherit version;
    sha256 = "3cdb5fbae183db49ab1f1a90643d521aa060c93f90001cc99c19d8d15b7a3fb7";
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

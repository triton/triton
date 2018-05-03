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
  version = "14.2.0";
in
buildPythonPackage rec {
  name = "cherrypy-${version}";

  src = fetchPyPi {
    package = "CherryPy";
    inherit version;
    sha256 = "d793223398ea62206f1ac1e98e4f6a7e2fda588fb78afb3774c3dae00888ac5c";
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

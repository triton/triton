{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, setuptools-scm
, six
}:

let
  version = "8.9.0";
in
buildPythonPackage rec {
  name = "cherrypy-${version}";

  src = fetchPyPi {
    package = "CherryPy";
    inherit version;
    sha256 = "38f505f08bd121e32c8bcb8e4869a9d7140735254464fe241229a2a60d386554";
  };

  propagatedBuildInputs = [
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

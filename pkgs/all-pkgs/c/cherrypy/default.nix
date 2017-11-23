{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, cheroot
, portend
, setuptools-scm
, six
}:

let
  version = "12.0.0";
in
buildPythonPackage rec {
  name = "cherrypy-${version}";

  src = fetchPyPi {
    package = "CherryPy";
    inherit version;
    sha256 = "e6f55c8b1c01c787b944a405775884ebae6b4f413420c28e41230cc4759bc41e";
  };

  propagatedBuildInputs = [
    cheroot
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

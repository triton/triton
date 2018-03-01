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
  version = "14.0.0";
in
buildPythonPackage rec {
  name = "cherrypy-${version}";

  src = fetchPyPi {
    package = "CherryPy";
    inherit version;
    sha256 = "5f5ee020d6547a8d452b3560775ca2374ffe2ff8c0aec1b272e93b6af80d850e";
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

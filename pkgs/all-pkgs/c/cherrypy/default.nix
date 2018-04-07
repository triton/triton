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
  version = "14.0.1";
in
buildPythonPackage rec {
  name = "cherrypy-${version}";

  src = fetchPyPi {
    package = "CherryPy";
    inherit version;
    sha256 = "721d09bbeedaf5b3493e9e644ae9285d776ea7f16b1d4a0a5aaec7c0d22e5074";
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

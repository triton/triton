{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, cheroot
, more-itertools
, portend
, setuptools-scm
, zc-lockfile
}:

let
  version = "18.1.2";
in
buildPythonPackage rec {
  name = "cherrypy-${version}";

  src = fetchPyPi {
    package = "CherryPy";
    inherit version;
    sha256 = "48de31ba3db04c5354a0fcf8acf21a9c5190380013afca746d50237c9ebe70f0";
  };

  propagatedBuildInputs = [
    cheroot
    more-itertools
    portend
    setuptools-scm
    zc-lockfile
  ];

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

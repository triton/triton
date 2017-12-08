{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, setuptools-scm
, six
}:

let
  version = "6.0.0";
in
buildPythonPackage rec {
  name = "cheroot-${version}";

  src = fetchPyPi {
    package = "cheroot";
    inherit version;
    sha256 = "ba474e5149b03fabc2bba2d0b490b4d95443894d45b1430b799dccea3b3f4683";
  };

  propagatedBuildInputs = [
    setuptools-scm
    six
  ];

  meta = with lib; {
    description = "Highly-optimized, pure-python HTTP server";
    homepage = https://github.com/cherrypy/cheroot;
    license = licenses.bsd3;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

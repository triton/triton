{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, setuptools-scm
, six
}:

let
  version = "5.10.0";
in
buildPythonPackage rec {
  name = "cheroot-${version}";

  src = fetchPyPi {
    package = "cheroot";
    inherit version;
    sha256 = "a408f1b80a3f93a3b49fc330f68eea40d8d30b9b07084f374607d1a5cc2e824f";
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

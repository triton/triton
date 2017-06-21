{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, setuptools-scm
, six
}:

let
  version = "5.6.0";
in
buildPythonPackage rec {
  name = "cheroot-${version}";

  src = fetchPyPi {
    package = "cheroot";
    inherit version;
    sha256 = "7d04b484f8340beff66008fcc44eee9b7528cdd20feec7495cba2763254c83c1";
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

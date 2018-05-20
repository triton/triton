{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, setuptools-scm
, six
}:

let
  version = "6.3.0";
in
buildPythonPackage rec {
  name = "cheroot-${version}";

  src = fetchPyPi {
    package = "cheroot";
    inherit version;
    sha256 = "56c07903580d51ebd456e764d2bef334e97025369cfe6af56357053a9ff72446";
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

{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, setuptools-scm
, six
}:

let
  version = "5.8.3";
in
buildPythonPackage rec {
  name = "cheroot-${version}";

  src = fetchPyPi {
    package = "cheroot";
    inherit version;
    sha256 = "5c0531fd732700b1fb3e6e7079dc3aefbdf29e9136925633d93f009cb87d70a3";
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

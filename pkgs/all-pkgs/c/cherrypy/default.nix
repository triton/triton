{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, setuptools-scm
, six
}:

let
  version = "8.9.1";
in
buildPythonPackage rec {
  name = "cherrypy-${version}";

  src = fetchPyPi {
    package = "CherryPy";
    inherit version;
    sha256 = "dfad2f34e929836d016ae79f9e27aff250a8a71df200bf87c3e9b23541e091c5";
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

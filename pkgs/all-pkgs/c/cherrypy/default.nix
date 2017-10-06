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
  version = "11.0.0";
in
buildPythonPackage rec {
  name = "cherrypy-${version}";

  src = fetchPyPi {
    package = "CherryPy";
    inherit version;
    sha256 = "5671f88c8dd8aecaac650761d18f74a2789b88a9337eb7433abe92a5e0be6780";
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

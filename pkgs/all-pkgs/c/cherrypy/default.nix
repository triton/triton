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
  version = "12.0.1";
in
buildPythonPackage rec {
  name = "cherrypy-${version}";

  src = fetchPyPi {
    package = "CherryPy";
    inherit version;
    sha256 = "6a3a90a43b1e05bd4634c60acfdcf34efe74f9f8746aca14dbe95a9b69db30ea";
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

{ stdenv
, buildPythonPackage
, fetchPyPi

, six
}:

buildPythonPackage rec {
  name = "cherrypy-${version}";
  version = "7.1.0";

  src = fetchPyPi {
    package = "CherryPy";
    inherit version;
    sha256 = "64dca80ccadae4ed8e4ea94119bf76ed9746743c2bd57ec40af534680cbef021";
  };

  propagatedBuildInputs = [
    six
  ];

  doCheck = false;

  meta = with stdenv.lib; {
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

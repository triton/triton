{ stdenv
, buildPythonPackage
, fetchPyPi

, six
}:

buildPythonPackage rec {
  name = "cherrypy-${version}";
  version = "6.0.2";

  src = fetchPyPi {
    package = "CherryPy";
    inherit version;
    sha256 = "3fce23f451c89948c585fbf4f7122f6fb688f33abcc738b781ca0d9bb794e2c5";
  };

  propagatedBuildInputs = [
    six
  ];

  doCheck = false;

  meta = with stdenv.lib; {
    description = "A pythonic, object-oriented HTTP framework";
    homepage = "http://www.cherrypy.org";
    license = licenses.bsd3;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

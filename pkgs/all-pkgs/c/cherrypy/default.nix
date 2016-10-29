{ stdenv
, buildPythonPackage
, fetchPyPi

, setuptools-scm
, six
}:

buildPythonPackage rec {
  name = "cherrypy-${version}";
  version = "8.1.2";

  src = fetchPyPi {
    package = "CherryPy";
    inherit version;
    sha256 = "45a92fdd18baa19d055e5f53bb3c4293821a30e83bf3c5244b867685397f5380";
  };

  propagatedBuildInputs = [
    setuptools-scm
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

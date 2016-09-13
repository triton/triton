{ stdenv
, buildPythonPackage
, fetchPyPi

, setuptools-scm
, six
}:

buildPythonPackage rec {
  name = "cherrypy-${version}";
  version = "8.1.0";

  src = fetchPyPi {
    package = "CherryPy";
    inherit version;
    sha256 = "b4fa89b76adcb909daded1f14a373413ad6c34bbb0f99e2c497c248e91dd616f";
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

{ stdenv
, buildPythonPackage
, fetchPyPi
}:

buildPythonPackage rec {
  name = "cherrypy-${version}";
  version = "5.4.0";

  src = fetchPyPi {
    package = "CherryPy";
    inherit version;
    sha256 = "bc8702099f6071ddd8b6404c110e22bb93e6a007fd9455e27f056be59a2ca801";
  };

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

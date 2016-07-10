{ stdenv
, buildPythonPackage
, fetchPyPi
, isPy3k

, zope-interface
}:

buildPythonPackage rec {
  name = "Twisted-${version}";
  version = "16.3.0";

  src = fetchPyPi {
    package = "Twisted";
    inherit version;
    type = ".tar.bz2";
    sha256 = "d588a87243ac20e72daef520c1248cb5391e1d583999b8c29a7ae5f97474974f";
  };

  propagatedBuildInputs = [
    zope-interface
  ];

  # Generate Twisted's plug-in cache.  Twisted users must do it as well.  See
  # http://twistedmatrix.com/documents/current/core/howto/plugin.html#plugin-caching
  # and http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=477103 for details.
  postInstall = "$out/bin/twistd --help > /dev/null";

  # Tests are not fully compatible with Python 3
  doCheck = !isPy3k;

  meta = with stdenv.lib; {
    description = "An event-driven networking engine written in Python";
    homepage = https://twistedmatrix.com/;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

{ stdenv
, buildPythonPackage
, fetchPyPi
, isPy3k

, zope-interface
}:

buildPythonPackage rec {
  name = "Twisted-${version}";
  version = "16.2.0";

  src = fetchPyPi {
    package = "Twisted";
    inherit version;
    type = ".tar.bz2";
    sha256 = "a090e8dc675e97fb20c3bb5f8114ae94169f4e29fd3b3cbede35705fd3cdbd79";
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

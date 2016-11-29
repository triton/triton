{ stdenv
, buildPythonPackage
, fetchPyPi
, isPy3k
, lib

, constantly
, incremental
, zope-interface
}:

let
  version = "16.6.0";
in
buildPythonPackage rec {
  name = "Twisted-${version}";

  src = fetchPyPi {
    package = "Twisted";
    inherit version;
    type = ".tar.bz2";
    sha256 = "d0fe115ea7ef8cf632d05103de60356c6e992b2153d6830bdc4476f8accb1fca";
  };

  propagatedBuildInputs = [
    constantly
    incremental
    zope-interface
  ];

  # Generate Twisted's plug-in cache.  Twisted users must do it as well.  See
  # http://twistedmatrix.com/documents/current/core/howto/plugin.html#plugin-caching
  # and http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=477103 for details.
  postInstall = "$out/bin/twistd --help > /dev/null";

  # Tests are not fully compatible with Python 3
  doCheck = !isPy3k;

  meta = with lib; {
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

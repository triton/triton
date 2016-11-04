{ stdenv
, buildPythonPackage
, fetchPyPi
, isPy3k

, constantly
, incremental
, zope-interface
}:

let
  version = "16.5.0";
in
buildPythonPackage rec {
  name = "Twisted-${version}";

  src = fetchPyPi {
    package = "Twisted";
    inherit version;
    type = ".tar.bz2";
    sha256 = "0207d88807482fa670a84926590e163a2a081a29745de34c5a6dc21066abae73";
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

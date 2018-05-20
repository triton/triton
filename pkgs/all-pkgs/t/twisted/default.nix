{ stdenv
, buildPythonPackage
, fetchPyPi
, isPy3
, lib

, automat
, constantly
, hyperlink
, idna
, incremental
, zope-interface
}:

let
  version = "18.4.0";
in
buildPythonPackage rec {
  name = "Twisted-${version}";

  src = fetchPyPi {
    package = "Twisted";
    inherit version;
    type = ".tar.bz2";
    sha256 = "a4cc164a781859c74de47f17f0e85f4bce8a3321a9d0892c015c8f80c4158ad9";
  };

  propagatedBuildInputs = [
    automat
    constantly
    hyperlink
    idna
    incremental
    zope-interface
  ];

  # Generate Twisted's plug-in cache.  Twisted users must do it as well.  See
  # http://twistedmatrix.com/documents/current/core/howto/plugin.html#plugin-caching
  # and http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=477103 for details.
  postInstall = "$out/bin/twistd --help > /dev/null";

  # Tests are not fully compatible with Python 3
  doCheck = !isPy3;

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

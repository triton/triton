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
  version = "17.9.0";
in
buildPythonPackage rec {
  name = "Twisted-${version}";

  src = fetchPyPi {
    package = "Twisted";
    inherit version;
    type = ".tar.bz2";
    sha256 = "0da1a7e35d5fcae37bc9c7978970b5feb3bc82822155b8654ec63925c05af75c";
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

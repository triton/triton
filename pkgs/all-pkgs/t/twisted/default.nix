{ stdenv
, buildPythonPackage
, fetchPyPi
, isPy3
, lib

, appdirs
, attrs
, automat
, bcrypt
, constantly
, cryptography
, h2
, hyperlink
, idna
, incremental
, priority
, pyasn1
, pyopenssl
, pyserial
, service-identity
, zope-interface
}:

let
  version = "18.9.0";
in
buildPythonPackage rec {
  name = "Twisted-${version}";

  src = fetchPyPi {
    package = "Twisted";
    inherit version;
    type = ".tar.bz2";
    sha256 = "294be2c6bf84ae776df2fc98e7af7d6537e1c5e60a46d33c3ce2a197677da395";
  };

  propagatedBuildInputs = [
    appdirs
    attrs
    automat
    bcrypt
    constantly
    cryptography
    h2
    hyperlink
    idna
    incremental
    priority
    pyasn1
    pyopenssl
    pyserial
    service-identity
    zope-interface
  ];

  # Generate Twisted's plug-in cache.  Twisted users must do it as well.  See
  # http://twistedmatrix.com/documents/current/core/howto/plugin.html#plugin-caching
  # and http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=477103 for details.
  postInstall = "$out/bin/twistd --help > /dev/null";

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

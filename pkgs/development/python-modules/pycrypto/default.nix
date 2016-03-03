{ stdenv
, buildPythonPackage
, fetchurl

, python
, pythonPackages
, gmp
}:

buildPythonPackage rec {
  name = "pycrypto-2.6.1";
  namePrefix = "";

  src = fetchurl {
    url = "http://pypi.python.org/packages/source/p/pycrypto/${name}.tar.gz";
    sha256 = "0g0ayql5b9mkjam8hym6zyg6bv77lbh66rv1fyvgqb17kfc1xkpj";
  };

  preConfigure = ''
    sed -i 's,/usr/include,/no-such-dir,' configure
    sed -i "s!,'/usr/include/'!!" setup.py
  '';

  buildInputs = stdenv.lib.optional (!pythonPackages.isPyPy or false) gmp; # optional for pypy

  doCheck = !(pythonPackages.isPyPy); # error: AF_UNIX path too long

  meta = {
    homepage = "http://www.pycrypto.org/";
    description = "Python Cryptography Toolkit";
    platforms = stdenv.lib.platforms.all;
  };
}

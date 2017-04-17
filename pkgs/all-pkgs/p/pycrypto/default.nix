{ stdenv
, buildPythonPackage
, fetchPyPi
}:

let
  version = "2.6.1";
in
buildPythonPackage rec {
  name = "pycrypto-${version}";

  src = fetchPyPi {
    package = "pycrypto";
    inherit version;
    sha256 = "f2ce1e989b272cfcb677616763e0a2e7ec659effa67a88aa92b3a65528f60a3c";
  };

  preConfigure = ''
    sed -i 's,/usr/include,/no-such-dir,' configure
    sed -i "s!,'/usr/include/'!!" setup.py
  '';

  meta = with stdenv.lib; {
    homepage = "http://www.pycrypto.org/";
    description = "Python Cryptography Toolkit";
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

{ stdenv
, buildPythonPackage
, fetchurl

, isPy3k
}:

buildPythonPackage rec {
  name = "futures-${version}";
  version = "3.0.5";

  src = fetchurl {
    url = "mirror://pypi/f/futures/${name}.tar.gz";
    sha256 = "0542525145d5afc984c88f914a0c85c77527f65946617edb5274f72406f981df";
  };

  # This module is for backporting Python 3.2 functionality to Python 2.x.
  disabled = isPy3k;

  meta = with stdenv.lib; {
    description = "Backport of the concurrent.futures package from Python 3.2";
    homepage = https://github.com/agronholm/pythonfutures;
    license = licenses.bsd2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

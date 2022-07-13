{stdenv, fetchurl, autoconf, automake, libtool}:

stdenv.mkDerivation rec {
  pName = "soundtouch";
  name = "${pName}-1.9.2";
  src = fetchurl {
    url = "http://www.surina.net/soundtouch/${name}.tar.gz";
    sha256 = "caeb86511e81420eeb454cb5db53f56d96b8451d37d89af6e55b12eb4da1c513";
  };

  buildInputs = [ autoconf automake libtool ];

  preConfigure = ''
    ./bootstrap
  '';

  meta = {
      description = "A program and library for changing the tempo, pitch and playback rate of audio";
      homepage = http://www.surina.net/soundtouch/;
      downloadPage = http://www.surina.net/soundtouch/sourcecode.html;
      license = stdenv.lib.licenses.lgpl21;
      platforms = stdenv.lib.platforms.all;
  };
}

{stdenv, fetchurl}:

stdenv.mkDerivation {
  name = "libungif-4.1.4";
  src = fetchurl {
    url = mirror://sourceforge/giflib/libungif-4.1.4.tar.gz;
    sha256 = "0gfsmf3mss5dvchfg6c1h6y2xvn2qraby3chi7jcvl5cvvjy2ray";
  };
}


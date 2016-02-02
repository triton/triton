{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  version = "3.0.7";
  name = "redis-${version}";

  src = fetchurl {
    url = "http://download.redis.io/releases/${name}.tar.gz";
    sha256 = "08vzfdr67gp3lvk770qpax2c5g2sx8hn6p64jn3jddrvxb2939xj";
  };

  makeFlags = "PREFIX=$(out)";

  meta = with stdenv.lib; {
    description = "An open source, advanced key-value store";
    homepage = http://redis.io;
    license = licenses.bsd3;
    maintainers = with maintainers; [ ];
    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];
  };
}

{stdenv, fetchurl, cyrus_sasl, libevent}:

stdenv.mkDerivation rec {
  name = "memcached-1.4.25";

  src = fetchurl {
    url = "http://memcached.org/files/${name}.tar.gz";
    sha256 = "1njxg6mh8bzzhzqcmh0qswp33cpd7r7bp9m934ck4k927ixl6n7h";
  };

  buildInputs = [cyrus_sasl libevent];

  meta = with stdenv.lib; {
    description = "A distributed memory object caching system";
    repositories.git = https://github.com/memcached/memcached.git;
    homepage = http://memcached.org/;
    license = licenses.bsd3;
    maintainers = [ maintainers.coconnor ];
    platforms = platforms.linux ++ platforms.darwin;
  };
}

{ stdenv
, fetchurl
}:

let
  version = "3.2.6";
in
stdenv.mkDerivation rec {
  name = "redis-${version}";

  src = fetchurl {
    url = "http://download.redis.io/releases/${name}.tar.gz";
    # https://github.com/antirez/redis-hashes/blob/master/README
    sha1Confirm = "0c7bc5c751bdbc6fabed178db9cdbdd948915d1b";
    sha256 = "2e1831c5a315e400d72bda4beaa98c0cfbe3f4eb8b20c269371634390cf729fa";
  };

  preBuild = ''
    makeFlagsArray+=(
      "MALLOC=jemalloc"
      "PREFIX=$out"
    )
  '';

  meta = with stdenv.lib; {
    description = "An open source, advanced key-value store";
    homepage = http://redis.io;
    license = licenses.bsd3;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

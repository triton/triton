{ stdenv
, fetchurl
}:

let
  version = "4.0.1";
in
stdenv.mkDerivation rec {
  name = "redis-${version}";

  src = fetchurl {
    url = "http://download.redis.io/releases/${name}.tar.gz";
    multihash = "QmSyPhvccwba87E4xY5Dg2jTkdxJJegQD4N7acdvKgfDgi";
    hashOutput = false;
    sha256 = "2049cd6ae9167f258705081a6ef23bb80b7eff9ff3d0d7481e89510f27457591";
  };

  preBuild = ''
    makeFlagsArray+=(
      "MALLOC=jemalloc"
      "PREFIX=$out"
    )
  '';

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      sha256Url = "https://raw.githubusercontent.com/antirez/redis-hashes/master/README";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

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

{ stdenv
, fetchurl
}:

let
  version = "4.0.8";
in
stdenv.mkDerivation rec {
  name = "redis-${version}";

  src = fetchurl {
    url = "http://download.redis.io/releases/${name}.tar.gz";
    multihash = "Qmabv43ZBTpFqXcd7QKphuVUEDwDw7pyTJRdCaLhokR3EC";
    hashOutput = false;
    sha256 = "ff0c38b8c156319249fec61e5018cf5b5fe63a65b61690bec798f4c998c232ad";
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

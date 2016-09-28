{ stdenv
, fetchurl
}:

let
  version = "3.2.4";
in
stdenv.mkDerivation rec {
  name = "redis-${version}";

  src = fetchurl {
    url = "http://download.redis.io/releases/${name}.tar.gz";
    # https://github.com/antirez/redis-hashes/blob/master/README
    sha1Confirm = "f0fe685cbfdb8c2d8c74613ad8a5a5f33fba40c9";
    sha256 = "2ad042c5a6c508223adeb9c91c6b1ae091394b4026f73997281e28914c9369f1";
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

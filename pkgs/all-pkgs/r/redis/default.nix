{ stdenv
, fetchurl
}:

let
  version = "3.2.5";
in
stdenv.mkDerivation rec {
  name = "redis-${version}";

  src = fetchurl {
    url = "http://download.redis.io/releases/${name}.tar.gz";
    # https://github.com/antirez/redis-hashes/blob/master/README
    sha1Confirm = "6f6333db6111badaa74519d743589ac4635eba7a";
    sha256 = "8509ceb1efd849d6b2346a72a8e926b5a4f6ed3cc7c3cd8d9f36b2e9ba085315";
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

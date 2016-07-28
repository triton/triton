{ stdenv
, fetchurl

, jemalloc
}:

let
  version = "3.2.2";
in
stdenv.mkDerivation rec {
  name = "redis-${version}";

  src = fetchurl {
    url = "http://download.redis.io/releases/${name}.tar.gz";
    sha1Confirm = "3141be9757532139f445bd5f6f4fae293bc33d27";
    sha256 = "05cf63502b2248b5d39588962100bfa4fcb47dabd56931a8cb60b301b1d8daea";
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

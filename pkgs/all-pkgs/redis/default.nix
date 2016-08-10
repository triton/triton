{ stdenv
, fetchurl

, jemalloc
}:

let
  version = "3.2.3";
in
stdenv.mkDerivation rec {
  name = "redis-${version}";

  src = fetchurl {
    url = "http://download.redis.io/releases/${name}.tar.gz";
    sha1Confirm = "92d6d93ef2efc91e595c8bf578bf72baff397507";
    sha256 = "674e9c38472e96491b7d4f7b42c38b71b5acbca945856e209cb428fbc6135f15";
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

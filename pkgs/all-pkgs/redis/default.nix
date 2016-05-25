{ stdenv
, fetchurl

, jemalloc
}:

let
  version = "3.2.0";
in
stdenv.mkDerivation rec {
  name = "redis-${version}";

  src = fetchurl {
    url = "http://download.redis.io/releases/${name}.tar.gz";
    sha1Confirm = "0c1820931094369c8cc19fc1be62f598bc5961ca";
    sha256 = "989f1af3dc0ac1828fdac48cd6c608f5a32a235046dddf823226f760c0fd8762";
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

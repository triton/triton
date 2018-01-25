{ stdenv
, fetchurl
}:

let
  version = "4.0.7";
in
stdenv.mkDerivation rec {
  name = "redis-${version}";

  src = fetchurl {
    url = "http://download.redis.io/releases/${name}.tar.gz";
    multihash = "QmTfVfPCYaFk1E5bG1FwHnMtz1S67YhPLTwyrbKjTwawvm";
    hashOutput = false;
    sha256 = "1bba546d44fb40e1fd8be1a15e1a9cc6484bceeea0bbd52919eebc656661ecd1";
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

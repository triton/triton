{ stdenv
, fetchurl
}:

let
  version = "4.0.2";
in
stdenv.mkDerivation rec {
  name = "redis-${version}";

  src = fetchurl {
    url = "http://download.redis.io/releases/${name}.tar.gz";
    multihash = "QmY2UWoLSjjbQFuQorgHeLWotGUxPDYDzB4zNcG9ddzs1y";
    hashOutput = false;
    sha256 = "b1a0915dbc91b979d06df1977fe594c3fa9b189f1f3d38743a2948c9f7634813";
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

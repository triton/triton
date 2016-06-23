{ stdenv
, fetchurl

, jemalloc
}:

let
  version = "3.2.1";
in
stdenv.mkDerivation rec {
  name = "redis-${version}";

  src = fetchurl {
    url = "http://download.redis.io/releases/${name}.tar.gz";
    sha1Confirm = "26c0fc282369121b4e278523fce122910b65fbbf";
    sha256 = "df7bfb7b527d99981eba3912ae22703764eb19adda1357818188b22fdd09d5c9";
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

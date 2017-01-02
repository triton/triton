{ stdenv
, fetchurl
, shared ? true
, static ? true
}:

assert static || shared;

let
  version = "1.2.9";

  tarballUrls = version: [
    "http://zlib.net/zlib-${version}.tar.xz"
  ];
in
stdenv.mkDerivation rec {
  name = "zlib-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    multihash = "QmaoDoqYRXzQ2joHwTn8195U23kArHUrG5DJp7KyDk4pg8";
    sha256 = "03d9c7f67976cf1389589782de46f45011053ea7f4222c2fb8c2cf9fd813bb68";
  };

  configureFlags = [
    (if static then "--static" else "")
    (if shared then "--shared" else "")
  ];

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "1.2.9";
      pgpsigUrls = map (n: "${n}.asc") urls;
      pgpKeyFingerprint = "5ED4 6A67 21D3 6558 7791  E2AA 783F CD8E 58BC AFBA";
      inherit (src) outputHashAlgo;
      outputHash = "03d9c7f67976cf1389589782de46f45011053ea7f4222c2fb8c2cf9fd813bb68";
    };
  };

  meta = with stdenv.lib; {
    description = "Lossless data-compression library";
    homepage = http://www.zlib.net/;
    license = licenses.zlib;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}

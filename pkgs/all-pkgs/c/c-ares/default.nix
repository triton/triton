{ stdenv
, fetchurl
}:

let
  tarballUrls = version: [
    "https://c-ares.haxx.se/download/c-ares-${version}.tar.gz"
  ];

  version = "1.13.0";
in
stdenv.mkDerivation rec {
  name = "c-ares-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    multihash = "QmY5YL2foq4NQQ9u5XQ6pyFa6LcBTjVF9JhZ5UKSAuCvab";
    hashOutput = false;
    sha256 = "03f708f1b14a26ab26c38abd51137640cb444d3ec72380b21b20f1a8d2861da7";
  };

  passthru = {
    srcVerification = fetchurl rec {
      inherit (src) outputHashAlgo;
      urls = tarballUrls "1.13.0";
      pgpsigUrls = map (n: "${n}.asc") urls;
      outputHash = "03f708f1b14a26ab26c38abd51137640cb444d3ec72380b21b20f1a8d2861da7";
      pgpKeyFingerprint = "27ED EAF2 2F3A BCEB 50DB  9A12 5CC9 08FD B71E 12C2";
      failEarly = true;
    };
  };

  meta = with stdenv.lib; {
    description = "A C library for asynchronous DNS requests";
    homepage = http://c-ares.haxx.se;
    license = licenses.mit;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}

{ stdenv
, fetchurl

, boost
, libevent
, openssl
, zlib
}:

let
  version = "0.9.3";
in
stdenv.mkDerivation rec {
  name = "thrift-${version}";

  src = fetchurl {
    url = "mirror://apache/thrift/${version}/${name}.tar.gz";
    hashOutput = false;
    sha256 = "b0740a070ac09adde04d43e852ce4c320564a292f26521c46b78e0641564969e";
  };

  buildInputs = [
    boost
    libevent
    openssl
    zlib
  ];

  configureFlags = [
    "--disable-tests"
    "--disable-tutorial"
    "--disable-coverage"
  ];

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.asc") src.urls;
      pgpKeyFingerprint = "9782 694B 8B54 B4AD D345  E52A BB06 368F 66B7 78F9";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

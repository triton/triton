{ stdenv
, fetchurl

, boost
, libevent
, openssl
, zlib
}:

let
  version = "0.11.0";
in
stdenv.mkDerivation rec {
  name = "thrift-${version}";

  src = fetchurl {
    url = "mirror://apache/thrift/${version}/${name}.tar.gz";
    hashOutput = false;
    sha256 = "c4ad38b6cb4a3498310d405a91fef37b9a8e79a50cd0968148ee2524d2fa60c2";
  };

  buildInputs = [
    boost
    libevent
    openssl
    zlib
  ];

  configureFlags = [
    "--disable-tests"
    "--enable-plugin"
    "--disable-tutorial"
  ];

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.asc") src.urls;
      pgpKeyFingerprints = [
        # Jake Farrell
        "9782 694B 8B54 B4AD D345  E52A BB06 368F 66B7 78F9"
        # Jens Geyer
        "8CD8 7F18 6F06 E958 EFCA  963D 76BD 340F C4B7 5865"
      ];
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

{ stdenv
, fetchurl

, boost
, libevent
, openssl
, zlib
}:

let
  version = "0.12.0";
in
stdenv.mkDerivation rec {
  name = "thrift-${version}";

  src = fetchurl {
    url = "mirror://apache/thrift/${version}/${name}.tar.gz";
    hashOutput = false;
    sha256 = "c336099532b765a6815173f62df0ed897528a9d551837d627c1f87fadad90428";
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
      inherit (src)
        urls
        outputHash
        outputHashAlgo;
      fullOpts = {
        pgpsigUrls = map (n: "${n}.asc") src.urls;
        pgpKeyFingerprints = [
          # Jake Farrell
          "9782 694B 8B54 B4AD D345  E52A BB06 368F 66B7 78F9"
          # Jens Geyer
          "8CD8 7F18 6F06 E958 EFCA  963D 76BD 340F C4B7 5865"
          # James E King
          "9348 F036 9A20 8184 00F8  7140 C6F2 B11B EDD0 2683"
        ];
      };
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

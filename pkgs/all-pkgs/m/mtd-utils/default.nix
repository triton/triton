{ stdenv
, fetchurl
, lib

, acl
, attr
, lzo
, util-linux_lib
, zlib
}:

stdenv.mkDerivation rec {
  name = "mtd-utils-2.0.1";

  src = fetchurl {
    url = "ftp://ftp.infradead.org/pub/mtd-utils/${name}.tar.bz2";
    multihash = "QmPAoove9VgbFkAYBRjLgHsVuFEeVynsSDuCPM1ngtAUcS";
    hashOutput = false;
    sha256 = "312baa0446e4e728ceb413c53533e41e547d1c13ffa0752b2f879fd289fc2f63";
  };
  
  buildInputs = [
    acl
    attr
    lzo
    util-linux_lib
    zlib
  ];

  configureFlags = [
    "--disable-tests"
  ];

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.asc") src.urls;
      pgpKeyFingerprint = "1306 3F72 3C9E 584A EACD  5B9B BCE5 DC3C 741A 02D1";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

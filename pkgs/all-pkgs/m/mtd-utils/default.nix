{ stdenv
, fetchurl
, lib

, acl
, lzo
, openssl
, util-linux_lib
, zlib
}:

stdenv.mkDerivation rec {
  name = "mtd-utils-2.1.0";

  src = fetchurl {
    url = "ftp://ftp.infradead.org/pub/mtd-utils/${name}.tar.bz2";
    multihash = "QmbQoz2cDharUvwpHQ8yNZ4abHYz5xEyoQLcY48RWarBj3";
    hashOutput = false;
    sha256 = "b4b995b06d93aee4125e8e44c05a1cae6eea545ca5a6e8a377405ee8aa454bd2";
  };
  
  buildInputs = [
    acl
    lzo
    openssl
    util-linux_lib
    zlib
  ];

  configureFlags = [
    "--disable-tests"
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
        pgpKeyFingerprint = "1306 3F72 3C9E 584A EACD  5B9B BCE5 DC3C 741A 02D1";
      };
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

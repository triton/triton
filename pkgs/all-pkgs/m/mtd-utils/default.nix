{ stdenv
, fetchurl
, lib

, acl
, lzo
, util-linux_lib
, zlib
}:

stdenv.mkDerivation rec {
  name = "mtd-utils-2.0.2";

  src = fetchurl {
    url = "ftp://ftp.infradead.org/pub/mtd-utils/${name}.tar.bz2";
    multihash = "QmS2YuAJ38SAkBX3jL5wSqVgHshBiGsAzW4xczH15B2bhj";
    hashOutput = false;
    sha256 = "fb3de61be8e932abb424e8ea3c30298f553d5f970ad158a737bb303bbf9660b8";
  };
  
  buildInputs = [
    acl
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

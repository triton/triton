{ stdenv
, fetchurl
, lib
}:

stdenv.mkDerivation rec {
  name = "ragel-6.10";

  src = fetchurl {
    url = "http://www.colm.net/files/ragel/${name}.tar.gz";
    multihash = "Qmeq37tgy7efGStv9nMPVppWEHHxMLnt7unmLKNrjncFEe";
    hashOutput = false;
    sha256 = "5f156edb65d20b856d638dd9ee2dfb43285914d9aa2b6ec779dac0270cd56c3f";
  };

  postFixup = ''
    rm -rv "$bin"/share
  '';

  outputs = [
    "bin"
    "man"
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
        pgpKeyFingerprint = "AED6 E2A1 85EE B379 F174  76D2 E012 D07A D0E3 CC30";
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

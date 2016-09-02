{ stdenv
, fetchurl

, libxml2
, readline
}:

stdenv.mkDerivation rec {
  name = "augeas-1.5.0";

  src = fetchurl {
    url = "http://download.augeas.net/${name}.tar.gz";
    hashOutput = false;
    multihash = "QmRW3q4gHMpABYou2APHi3QDKkG9KY9xsAzn2e7uzRuYEM";
    sha256 = "223bb6e6fe3e9e92277dafd5d34e623733eb969a72a382998d204feab253f73f";
  };

  buildInputs = [
    libxml2
    readline
  ];

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.sig") src.urls;
      pgpKeyFingerprint = "AED6 E2A1 85EE B379 F174  76D2 E012 D07A D0E3 CC30";
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

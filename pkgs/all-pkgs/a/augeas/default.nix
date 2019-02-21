{ stdenv
, fetchurl
, lib

, libxml2
, readline
}:

stdenv.mkDerivation rec {
  name = "augeas-1.11.0";

  src = fetchurl {
    url = "http://download.augeas.net/${name}.tar.gz";
    multihash = "QmaW7QAgt492ZPomXmw94LVwxvUERseif6kHbBY3C34GWy";
    hashOutput = false;
    sha256 = "393ce8f4055af89cd4c20bf903eacbbd909cf427891f41b56dc2ba66243ea0b0";
  };

  buildInputs = [
    libxml2
    readline
  ];

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      inherit (src)
        urls
        outputHash
        outputHashAlgo;
      fullOpts = {
        pgpsigUrls = map (n: "${n}.sig") src.urls;
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

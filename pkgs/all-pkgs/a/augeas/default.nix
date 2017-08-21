{ stdenv
, fetchurl

, libxml2
, readline
}:

stdenv.mkDerivation rec {
  name = "augeas-1.8.1";

  src = fetchurl {
    url = "http://download.augeas.net/${name}.tar.gz";
    multihash = "QmRZ4M7q3m8dkXqCR2sxb5FTWw87DVP8czvZPw9vmUChZU";
    hashOutput = false;
    sha256 = "65cf75b5a573fee2a5c6c6e3c95cad05f0101e70d3f9db10d53f6cc5b11bc9f9";
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

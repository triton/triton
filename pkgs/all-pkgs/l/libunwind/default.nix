{ stdenv
, fetchurl

, xz
}:

stdenv.mkDerivation rec {
  name = "libunwind-1.2-rc1";

  src = fetchurl {
    url = "mirror://savannah/libunwind/${name}.tar.gz";
    hashOutput = false;
    sha256 = "d222f186b6bc60f49dac5030516ec35a7ed0ccca675551d6cf81008112116abc";
  };

  buildInputs = [
    xz
  ];

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.sig") src.urls;
      pgpKeyFingerprint = "5C96 BDEA F5F4 7FB0 2BD4  F6B9 65D9 8560 914F 3F48";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    homepage = http://www.nongnu.org/libunwind;
    description = "A portable and efficient API to determine the call-chain of a program";
    license = licenses.gpl2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "spice-protocol-0.12.12";

  src = fetchurl {
    url = "https://www.spice-space.org/download/releases/${name}.tar.bz2";
    hashOutput = false;
    sha256 = "17abdc2743b5d44b0f4423b61c44aafe9f2078c27218aeea78c2d02a5c409d03";
  };

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.sign") src.urls;
      pgpKeyFingerprint = "AED6 E2A1 85EE B379 F174  76D2 E012 D07A D0E3 CC30";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    description = "Protocol headers for the SPICE protocol";
    homepage = http://www.spice-space.org;
    license = licenses.bsd3;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

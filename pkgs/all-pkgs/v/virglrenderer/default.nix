{ stdenv
, fetchurl
, lib

, libdrm
, libepoxy
, libx11
, opengl-dummy
}:

stdenv.mkDerivation rec {
  name = "virglrenderer-0.6.0";

  src = fetchurl {
    url = "https://www.freedesktop.org/software/virgl/${name}.tar.bz2";
    multihash = "QmRxLivBGoC63CNdjGAGghLtz9YbKFcURsbAPTFQ8tR1cG";
    hashOutput = false;
    sha256 = "a549e351e0eb2ad1df471386ddcf85f522e7202808d1616ee9ff894209066e1a";
  };

  buildInputs = [
    libdrm
    libepoxy
    libx11
    opengl-dummy
  ];

  configureFlags = [
    "--disable-tests"
    "--with-glx"
  ];

  passthru = {
    srcVerification = fetchurl {
      failEarly = false;
      pgpsigUrls = map (n: "${n}.sig") src.urls;
      pgpKeyFingerprint = "10A6 D91D A1B0 5BD2 9F6D  EBAC 0C74 F359 79C4 86BE";
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

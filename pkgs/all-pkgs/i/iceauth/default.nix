{ stdenv
, fetchurl
, lib
, util-macros

, libice
, xorgproto
}:

stdenv.mkDerivation rec {
  name = "iceauth-1.0.8";

  src = fetchurl {
    url = "mirror://xorg/individual/app/${name}.tar.bz2";
    hashOutput = false;
    sha256 = "e6ee213a217265cc76050e4293ea70b98c32dce6505c6421227efbda62ab60c6";
  };

  nativeBuildInputs = [
    util-macros
  ];

  buildInputs = [
    libice
    xorgproto
  ];

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      pgpsigUrls = map (n: "${n}.sig") src.urls;
      pgpKeyFingerprints = [
        # Alan Coopersmith
        "4A19 3C06 D35E 7C67 0FA4  EF0B A2FB 9E08 1F2D 130E"
      ];
      failEarly = true;
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

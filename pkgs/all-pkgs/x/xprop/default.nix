{ stdenv
, fetchurl
, lib
, util-macros

, libx11
, xorgproto
}:

stdenv.mkDerivation rec {
  name = "xprop-1.2.3";

  src = fetchurl {
    url = "mirror://xorg/individual/app/${name}.tar.bz2";
    hashOutput = false;
    sha256 = "d22afb28c86d85fff10a50156a7d0fa930c80ae865d70b26d805fd28a17a521b";
  };

  nativeBuildInputs = [
    util-macros
  ];

  buildInputs = [
    libx11
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

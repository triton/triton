{ stdenv
, fetchurl
, lib
, util-macros

, libx11
, libxcursor
, libxmu
, xbitmaps
, xorgproto
}:

stdenv.mkDerivation rec {
  name = "xsetroot-1.1.2";

  src = fetchurl {
    url = "mirror://xorg/individual/app/${name}.tar.bz2";
    hashOutput = false;
    sha256 = "10c442ba23591fb5470cea477a0aa5f679371f4f879c8387a1d9d05637ae417c";
  };

  nativeBuildInputs = [
    util-macros
  ];

  buildInputs = [
    libx11
    libxcursor
    libxmu
    xbitmaps
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

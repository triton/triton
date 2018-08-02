{ stdenv
, fetchurl
, lib
, util-macros
}:

stdenv.mkDerivation rec {
  name = "xbitmaps-1.1.2";

  src = fetchurl {
    url = "mirror://xorg/individual/data/${name}.tar.bz2";
    hashOutput = false;
    sha256 = "b9f0c71563125937776c8f1f25174ae9685314cbd130fb4c2efce811981e07ee";
  };

  nativeBuildInputs = [
    util-macros
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

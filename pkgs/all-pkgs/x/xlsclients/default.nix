{ stdenv
, fetchurl
, lib
, util-macros

, libxcb
}:

stdenv.mkDerivation rec {
  name = "xlsclients-1.1.4";

  src = fetchurl {
    url = "mirror://xorg/individual/app/${name}.tar.bz2";
    hashOutput = false;
    sha256 = "773f2af49c7ea2c44fba4213bee64325875c1b3c9bc4bbcd8dac9261751809c1";
  };

  nativeBuildInputs = [
    util-macros
  ];

  buildInputs = [
    libxcb
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

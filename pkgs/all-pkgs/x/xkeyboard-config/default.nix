{ stdenv
, fetchurl
, intltool
, lib
, util-macros

, libx11
, xorgproto
}:

stdenv.mkDerivation rec {
  name = "xkeyboard-config-2.23.1";

  src = fetchurl {
    url = "mirror://xorg/individual/data/xkeyboard-config/${name}.tar.bz2";
    hashOutput = false;
    sha256 = "2a4bbc05fea22151b7a7c8ac2655d549aa9b0486bedc7f5a68c72716343b02f3";
  };

  nativeBuildInputs = [
    intltool
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
        # Sergey Udaltsov
        "FFB4 CCD2 75AA A422 F5F9  808E 0661 D98F C933 A145"
      ];
      failEarly = true;
    };
  };

  meta = with lib; {
    description = "X keyboard configuration files";
    homepage = https://xorg.freedesktop.org;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

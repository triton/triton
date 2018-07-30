{ stdenv
, fetchurl
, intltool
, lib
, libxslt
, util-macros

, libx11
, xorgproto
}:

stdenv.mkDerivation rec {
  name = "xkeyboard-config-2.24";

  src = fetchurl {
    url = "mirror://xorg/individual/data/xkeyboard-config/${name}.tar.bz2";
    hashOutput = false;
    sha256 = "91b18580f46b4e4ea913707f6c8d68ab5286879c3a6591462f3b9e760d3ac4d7";
  };

  nativeBuildInputs = [
    intltool
    libxslt
    util-macros
  ];

  buildInputs = [
    libx11
    xorgproto
  ];

  postInstall = ''
    ln -sv $out/share/ $out/etc
  '';

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

{ stdenv
, bison
, fetchurl
, lib
, util-macros

, libx11
, libxkbfile
, xorg
, xorgproto
}:

stdenv.mkDerivation rec {
  name = "xkbcomp-1.4.1";

  src = fetchurl {
    url = "mirror://xorg/individual/app/${name}.tar.bz2";
    sha256 = "748dc4cf58ac95684106bd9cf163ac6ab7de9a236faec02a6f4d4006d63a5736";
  };

  nativeBuildInputs = [
    bison
    util-macros
  ];

  buildInputs = [
    libx11
    libxkbfile
    xorgproto
  ];

  configureFlags = [
    "--with-xkb-config-root=${xorg.xkeyboardconfig}/share/X11/xkb"
  ];

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      pgpsigUrls = map (n: "${n}.sig") src.urls;
      pgpKeyFingerprints = [
        # Adam Jackson
        "DD38 563A 8A82 2453 7D1F  90E4 5B8A 2D50 A0EC D0D3"
        "995E D5C8 A613 8EB0 961F  1847 4C09 DD83 CAAA 50B2"
      ];
      failEarly = true;
    };
  };

  meta = with lib; {
    description = "X Keyboard description compiler";
    homepage = https://xorg.freedesktop.org/;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

{ stdenv
, bison
, fetchurl
, lib
, util-macros

, libx11
, libxkbfile
, xkeyboard-config
, xorgproto
}:

stdenv.mkDerivation rec {
  name = "xkbcomp-1.4.2";

  src = fetchurl {
    url = "mirror://xorg/individual/app/${name}.tar.bz2";
    hashOutput = false;
    sha256 = "6dd8bcb9be7e85bd7294abe261b8c7b0539d2fc93e41b80fb8bd013767ce8424";
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
    "--with-xkb-config-root=${xkeyboard-config}/share/X11/xkb"
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

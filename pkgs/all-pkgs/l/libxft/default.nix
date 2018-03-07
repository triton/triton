{ stdenv
, fetchurl
, lib
, util-macros

, fontconfig
, freetype
, libx11
, libxrender
, xorgproto
}:

stdenv.mkDerivation rec {
  name = "libXft-2.3.2";

  src = fetchurl {
    url = "mirror://xorg/individual/lib/${name}.tar.bz2";
    hashOutput = false;
    sha256 = "f5a3c824761df351ca91827ac221090943ef28b248573486050de89f4bfcdc4c";
  };

  nativeBuildInputs = [
    util-macros
  ];

  buildInputs = [
    fontconfig
    freetype
    libx11
    libxrender
    xorgproto
  ];

  configureFlags = [
    "--enable-selective-werror"
    "--disable-strict-compilation"
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
    description = "Client side font rendering library";
    homepage = https://xorg.freedesktop.org;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

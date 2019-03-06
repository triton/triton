{ stdenv
, fetchurl
, lib
, util-macros

, xorgproto
}:

stdenv.mkDerivation rec {
  name = "libXau-1.0.9";

  src = fetchurl {
    url = "mirror://xorg/individual/lib/${name}.tar.bz2";
    hashOutput = false;
    sha256 = "ccf8cbf0dbf676faa2ea0a6d64bcc3b6746064722b606c8c52917ed00dcb73ec";
  };

  nativeBuildInputs = [
    util-macros
  ];

  buildInputs = [
    xorgproto
  ];

  configureFlags = [
    "--enable-selective-werror"
    "--disable-strict-compilation"
    "--disable-lint-library"
    "--without-lint"
  ];

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      fullOpts = {
        pgpsigUrls = map (u: "${u}.sig") src.urls;
        pgpKeyFingerprints = [
          # Alan Coopersmith
          "4A19 3C06 D35E 7C67 0FA4  EF0B A2FB 9E08 1F2D 130E"
        ];
      };
      failEarly = true;
    };
  };

  meta = with lib; {
    description = "X.Org X authorization library";
    homepage = https://xorg.freedesktop.org;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

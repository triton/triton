{ stdenv
, fetchurl
, lib
, util-macros

, libx11
, libxext
, xorgproto
}:

stdenv.mkDerivation rec {
  name = "libXScrnSaver-1.2.3";

  src = fetchurl {
    url = "mirror://xorg/individual/lib/${name}.tar.bz2";
    hashOutput = false;
    sha256 = "f917075a1b7b5a38d67a8b0238eaab14acd2557679835b154cf2bca576e89bf8";
  };

  nativeBuildInputs = [
    util-macros
  ];

  buildInputs = [
    libx11
    libxext
    xorgproto
  ];

  configureFlags = [
    "--disable-maintainer-mode"
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
          # Adam Jackson
          "995E D5C8 A613 8EB0 961F  1847 4C09 DD83 CAAA 50B2"
        ];
      };
      failEarly = true;
    };
  };

  meta = with lib; {
    description = "MIT-SCREEN-SAVER extension";
    homepage = https://xorg.freedesktop.org;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

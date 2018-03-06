{ stdenv
, fetchurl
, lib
, util-macros

, xorgproto
, zlib
}:

stdenv.mkDerivation rec {
  name = "libfontenc-1.1.3";

  src = fetchurl {
    url = "mirror://xorg/individual/lib/${name}.tar.bz2";
    hashOutput = false;
    sha256 = "70588930e6fc9542ff38e0884778fbc6e6febf21adbab92fd8f524fe60aefd21";
  };

  nativeBuildInputs = [
    util-macros
  ];

  buildInputs = [
    xorgproto
    zlib
  ];

  configureFlags = [
    "--enable-selective-werror"
    "--disable-strict-compilation"
    "--without-lint"
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
    description = "Font encoding library";
    homepage = https://xorg.freedesktop.org;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

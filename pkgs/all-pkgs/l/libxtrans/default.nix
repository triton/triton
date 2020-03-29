{ stdenv
, fetchurl
, lib
, util-macros
}:

stdenv.mkDerivation rec {
  name = "xtrans-1.4.0";

  src = fetchurl {
    url = "mirror://xorg/individual/lib/${name}.tar.bz2";
    hashOutput = false;
    sha256 = "377c4491593c417946efcd2c7600d1e62639f7a8bbca391887e2c4679807d773";
  };

  # Required for libx11 to compile
  postPatch = ''
    sed -i '\,sys/stropts.h,d' Xtranslcl.c
  '';

  nativeBuildInputs = [
    util-macros
  ];

  configureFlags = [
    "--disable-docs"
  ];

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      pgpsigUrls = map (n: "${n}.sig") src.urls;
      pgpKeyFingerprints = [
        # Keith Packard
        "C383 B778 2556 13DF DB40  9D91 DB22 1A69 0000 0011"
      ];
      failEarly = true;
    };
  };

  meta = with lib; {
    description = "X.Org xtrans library";
    homepage = https://xorg.freedesktop.org;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

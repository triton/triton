{ stdenv
, fetchurl
, lib

, util-macros
}:

stdenv.mkDerivation rec {
  name = "xproto-7.0.31";

  src = fetchurl {
    url = "mirror://xorg/individual/proto/${name}.tar.bz2";
    hashOutput = false;
    sha256 = "c6f9747da0bd3a95f86b17fb8dd5e717c8f3ab7f0ece3ba1b247899ec1ef7747";
  };

  nativeBuildInputs = [
    util-macros
  ];

  configureFlags = [
    "--enable-selective-werror"
    "--disable-strict-compilation"
    "--disable-specs"
    "--enable-function-prototypes"
    "--enable-varargs-prototypes"
    "--enable-const-prototypes"
    "--enable-nested-prototypes"
    "--enable-wide-prototypes"
    "--without-xmlto"
    "--without-fop"
    "--without-xsltproc"
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
    description = "X.Org xproto protocol headers";
    homepage = https://xorg.freedesktop.org;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

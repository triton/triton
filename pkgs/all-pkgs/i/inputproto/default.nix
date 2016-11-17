{ stdenv
, fetchurl
, lib
, util-macros
}:

stdenv.mkDerivation rec {
  name = "inputproto-2.3.2";

  src = fetchurl {
    url = "mirror://xorg/individual/proto/${name}.tar.bz2";
    hashOutput = false;
    sha256 = "893a6af55733262058a27b38eeb1edc733669f01d404e8581b167f03c03ef31d";
  };

  nativeBuildInputs = [
    util-macros
  ];

  configureFlags = [
    "--enable-selective-werror"
    "--disable-strict-compilation"
    "--disable-specs"
    "--without-asciidoc"
  ];

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      pgpsigUrls = map (n: "${n}.sig") src.urls;
      pgpKeyFingerprints = [
        # Peter Hutterer
        "3C2C 43D9 447D 5938 EF45  51EB E23B 7E70 B467 F0BF"
      ];
      failEarly = true;
    };
  };

  meta = with lib; {
    description = "X.Org Input protocol headers";
    homepage = https://xorg.freedesktop.org;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

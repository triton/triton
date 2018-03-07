{ stdenv
, fetchurl
, lib
, util-macros

, libx11
, xorgproto
}:

stdenv.mkDerivation rec {
  name = "libXext-1.3.3";

  src = fetchurl {
    url = "mirror://xorg/individual/lib/${name}.tar.bz2";
    hashOutput = false;
    sha256 = "b518d4d332231f313371fdefac59e3776f4f0823bcb23cf7c7305bfb57b16e35";
  };

  nativeBuildInputs = [
    util-macros
  ];

  buildInputs = [
    libx11
    xorgproto
  ];

  configureFlags = [
    "--enable-selective-werror"
    "--disable-strict-compilation"
    "--disable-specs"
    "--disable-lint-library"
    "--without-xmlto"
    "--without-fop"
    "--without-xsltproc"
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
        "3C2C 43D9 447D 5938 EF45  51EB E23B 7E70 B467 F0BF"
      ];
      failEarly = true;
    };
  };

  meta = with lib; {
    description = "Common X Extensions library";
    homepage = https://xorg.freedesktop.org;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

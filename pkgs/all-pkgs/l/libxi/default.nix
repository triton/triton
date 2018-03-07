{ stdenv
, fetchurl
, lib
, util-macros

, libx11
, libxext
, libxfixes
, xorgproto
}:

stdenv.mkDerivation rec {
  name = "libXi-1.7.9";

  src = fetchurl {
    url = "mirror://xorg/individual/lib/${name}.tar.bz2";
    hashOutput = false;
    sha256 = "c2e6b8ff84f9448386c1b5510a5cf5a16d788f76db018194dacdc200180faf45";
  };

  nativeBuildInputs = [
    util-macros
  ];

  buildInputs = [
    libx11
    libxext
    libxfixes
    xorgproto
  ];

  configureFlags = [
    "--enable-selective-werror"
    "--disable-strict-compilation"
    "--disable-docs"
    "--disable-specs"
    "--without-xmlto"
    "--without-fop"
    "--without-xsltproc"
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
    description = "Client library for XInput";
    homepage = https://xorg.freedesktop.org;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

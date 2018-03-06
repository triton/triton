{ stdenv
, fetchurl
, lib
, util-macros
}:

stdenv.mkDerivation rec {
  name = "xtrans-1.3.5";

  src = fetchurl {
    url = "mirror://xorg/individual/lib/${name}.tar.bz2";
    hashOutput = false;
    sha256 = "adbd3b36932ce4c062cd10f57d78a156ba98d618bdb6f50664da327502bc8301";
  };

  nativeBuildInputs = [
    util-macros
  ];

  configureFlags = [
    "--enable-selective-werror"
    "--disable-strict-compilation"
    "--disable-docs"
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

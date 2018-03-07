{ stdenv
, fetchurl
, lib
, util-macros

, libbsd
, xorgproto
}:

stdenv.mkDerivation rec {
  name = "libXdmcp-1.1.2";

  src = fetchurl {
    url = "mirror://xorg/individual/lib/${name}.tar.bz2";
    hashOutput = false;
    sha256 = "81fe09867918fff258296e1e1e159f0dc639cb30d201c53519f25ab73af4e4e2";
  };

  nativeBuildInputs = [
    util-macros
  ];

  buildInputs = [
    libbsd
    xorgproto
  ];

  configureFlags = [
    "--enable-selective-werror"
    "--disable-strict-compilation"
    "--disable-docs"
    "--disable-lint-library"
    "--disable-unit-tests"
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
        # Alan Coopersmith
        "4A19 3C06 D35E 7C67 0FA4  EF0B A2FB 9E08 1F2D 130E"
      ];
      failEarly = true;
    };
  };

  meta = with lib; {
    description = "X Display Manager Control Protocol routines";
    homepage = https://xorg.freedesktop.org;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

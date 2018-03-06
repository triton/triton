{ stdenv
, fetchurl
, lib
, util-macros

, libbsd
, xorgproto
, xtrans
}:

stdenv.mkDerivation rec {
  name = "libICE-1.0.9";

  src = fetchurl {
    url = "mirror://xorg/individual/lib/${name}.tar.bz2";
    hashOutput = false;
    sha256 = "8f7032f2c1c64352b5423f6b48a8ebdc339cc63064af34d66a6c9aa79759e202";
  };

  nativeBuildInputs = [
    util-macros
  ];

  buildInputs = [
    libbsd
    xorgproto
    xtrans
  ];

  configureFlags = [
    "--enable-selective-werror"
    "--disable-strict-compilation"
    "--disable-docs"
    "--disable-specs"
    "--enable-unix-transport"
    "--enable-tcp-transport"
    "--enable-ipv6"
    "--enable-local-transport"
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
        # Alan Coopersmith
        "4A19 3C06 D35E 7C67 0FA4  EF0B A2FB 9E08 1F2D 130E "
      ];
      failEarly = true;
    };
  };

  meta = with lib; {
    description = "X.Org Inter-Client Exchange library";
    homepage = https://xorg.freedesktop.org;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

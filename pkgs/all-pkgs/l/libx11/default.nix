{ stdenv
, fetchurl
, lib
, perl
, util-macros

, libxcb
, xorgproto
, xtrans
}:

let
  inherit (lib)
    boolEn
    boolWt;
in
stdenv.mkDerivation rec {
  name = "libX11-1.6.5";

  src = fetchurl {
    url = "mirror://xorg/individual/lib/${name}.tar.bz2";
    hashOutput = false;
    sha256 = "4d3890db2ba225ba8c55ca63c6409c1ebb078a2806de59fb16342768ae63435d";
  };

  nativeBuildInputs = [
    perl
    util-macros
  ];

  buildInputs = [
    libxcb
    xorgproto
    xtrans
  ];

  configureFlags = [
    "--enable-selective-werror"
    "--disable-strict-compilation"
    "--disable-specs"
    "--enable-unix-transport"
    "--enable-tcp-transport"
    "--enable-ipv6"
    "--enable-local-transport"
    "--enable-loadable-i18n"
    "--enable-loadable-xcursor"
    "--enable-xthreads"
    "--enable-xcms"
    "--enable-xlocale"
    "--enable-xf86bigfont"
    "--enable-xkb"
    "--enable-composecache"
    "--disable-lint-library"
    "--without-xmlto"
    "--without-fop"
    "--without-xsltproc"
    "--${boolWt (perl != null)}-perl"
    "--without-launchd"
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
        # Matt Turner
        "3BB6 39E5 6F86 1FA2 E865  0569 0FDD 682D 974C A72A"
        # Matthieu Herrb
        "C41C 985F DCF1 E536 4576  638B 6873 93EE 37D1 28F8"
      ];
      failEarly = true;
    };
  };

  meta = with lib; {
    description = "X.Org X11 library";
    homepage = https://xorg.freedesktop.org;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

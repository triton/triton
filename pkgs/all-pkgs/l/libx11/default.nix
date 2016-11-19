{ stdenv
, fetchurl
, lib
, perl
, util-macros

, inputproto
, kbproto
, libxcb
, xextproto
, xf86bigfontproto
, xproto
, xtrans
}:

let
  inherit (lib)
    boolEn
    boolWt;
in
stdenv.mkDerivation rec {
  name = "libX11-1.6.4";

  src = fetchurl {
    url = "mirror://xorg/individual/lib/${name}.tar.bz2";
    hashOutput = false;
    sha256 = "b7c748be3aa16ec2cbd81edc847e9b6ee03f88143ab270fb59f58a044d34e441";
  };

  nativeBuildInputs = [
    perl
    util-macros
  ];

  buildInputs = [
    inputproto
    kbproto
    libxcb
    xextproto
    xf86bigfontproto
    xproto
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
    "--${boolEn (xf86bigfontproto != null)}-xf86bigfont"
    "--${boolEn (inputproto != null && kbproto != null)}-xkb"
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

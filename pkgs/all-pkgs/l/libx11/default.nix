{ stdenv
, fetchurl
, lib
, perl
, util-macros

, libxcb
, libxtrans
, xorgproto
}:

let
  inherit (lib)
    boolEn
    boolWt;
in
stdenv.mkDerivation rec {
  name = "libX11-1.6.9";

  src = fetchurl {
    url = "mirror://xorg/individual/lib/${name}.tar.bz2";
    hashOutput = false;
    sha256 = "9cc7e8d000d6193fa5af580d50d689380b8287052270f5bb26a5fb6b58b2bed1";
  };

  nativeBuildInputs = [
    perl
    util-macros
  ];

  buildInputs = [
    libxcb
    libxtrans
    xorgproto
  ];

  configureFlags = [
    "--disable-specs"
    "--enable-unix-transport"
    "--enable-tcp-transport"
    "--enable-ipv6"
    "--enable-local-transport"
    "--enable-loadable-i18n"
    "--enable-loadable-xcursor"
    "--without-xmlto"
    "--without-fop"
    "--without-xsltproc"
    "--${boolWt (perl != null)}-perl"
    "--without-launchd"
  ];

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      fullOpts = {
        pgpsigUrls = map (n: "${n}.sig") src.urls;
        pgpKeyFingerprints = [
          # Matt Turner
          "3BB6 39E5 6F86 1FA2 E865  0569 0FDD 682D 974C A72A"
          # Matthieu Herrb
          "C41C 985F DCF1 E536 4576  638B 6873 93EE 37D1 28F8"
        ];
      };
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

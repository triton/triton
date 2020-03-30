{ stdenv
, fetchurl
, lib
, util-macros

, libice
, libxtrans
, util-linux_lib
, xorgproto
}:

let
  inherit (lib)
    boolWt;
in
stdenv.mkDerivation rec {
  name = "libSM-1.2.3";

  src = fetchurl {
    url = "mirror://xorg/individual/lib/${name}.tar.bz2";
    hashOutput = false;
    sha256 = "2d264499dcb05f56438dee12a1b4b71d76736ce7ba7aa6efbf15ebb113769cbb";
  };

  nativeBuildInputs = [
    util-macros
  ];

  buildInputs = [
    libice
    libxtrans
    util-linux_lib
    xorgproto
  ];

  configureFlags = [
    "--enable-selective-werror"
    "--disable-strict-compilation"
    "--disable-docs"
    "--enable-unix-transport"
    "--enable-tcp-transport"
    "--enable-ipv6"
    "--enable-local-transport"
    "--without-xmlto"
    "--without-fop"
    "--without-xsltproc"
    "--${boolWt (util-linux_lib != null)}-libuuid"
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
    description = "X.Org Session Management library";
    homepage = https://xorg.freedesktop.org;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

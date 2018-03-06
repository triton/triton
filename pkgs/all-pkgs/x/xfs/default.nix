{ stdenv
, fetchurl
, lib
, util-macros

, libxfont2
, xorgproto
, xtrans
}:

stdenv.mkDerivation rec {
  name = "xfs-1.2.0";

  src = fetchurl {
    url = "mirror://xorg/individual/app/${name}.tar.bz2";
    hashOutput = false;
    sha256 = "db2212115783498f8eeaaee1349461d6c4e9d2005e142bacd3a984fe57269860";
  };

  nativeBuildInputs = [
    util-macros
  ];

  buildInputs = [
    libxfont2
    xorgproto
    xtrans
  ];

  configureFlags = [
    "--enable-devel-docs"
    "--enable-inetd"
    "--enable-syslog"
    "--enable-unix-transport"
    "--disable-tcp-transport"
    "--enable-ipv6"
    "--enable-local-transport"
    "--without-xmlto"
    "--without-fop"
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
        # Adam Jackson
        "DD38 563A 8A82 2453 7D1F  90E4 5B8A 2D50 A0EC D0D3"
      ];
      failEarly = true;
    };
  };

  meta = with lib; {
    description = "X Font Server";
    homepage = https://xorg.freedesktop.org;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

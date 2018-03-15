{ stdenv
, fetchurl
, lib
, util-macros

, libx11
, libxcb
, xorgproto
}:

stdenv.mkDerivation rec {
  name = "xwininfo-1.1.4";

  src = fetchurl {
    url = "mirror://xorg/individual/app/${name}.tar.bz2";
    sha256 = "839498aa46b496492a5c65cd42cd2e86e0da88149b0672e90cb91648f8cd5b01";
  };

  nativeBuildInputs = [
    util-macros
  ];

  buildInputs = [
    libx11
    libxcb
    xorgproto
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--enable-rpath"
    "--disable-strict-compilation"
    #"--with-xcb-iccm"
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
    description = "Window information utility for X";
    homepage = https://xorg.freedesktop.org;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

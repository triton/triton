{ stdenv
, fetchurl
, lib

, file
, inputproto
, kbproto
, libx11
, libxext
, ncurses
, randrproto
, systemd_lib
, xproto
, xorg
}:

stdenv.mkDerivation rec {
  name = "xf86-input-wacom-0.35.0";

  src = fetchurl {
    url = "mirror://sourceforge/linuxwacom/${name}.tar.bz2";
    multihash = "QmPA6Kjv4JcADphnrnk4VSwssCQXyp8dKsMm7EmH9JnrC7";
    hashOutput = false;
    sha256 = "55f60a71e81ef5544885652069a4f52b5cbaceabba53a28ac1397ec0ac26447d";
  };

  buildInputs = [
    ncurses
    systemd_lib
    inputproto
    kbproto
    libx11
    libxext
    xorg.libXi
    xorg.libXinerama
    xorg.libXrandr
    xorg.libXrender
    xorg.pixman
    randrproto
    xorg.xorgserver
    xproto
  ];

  preConfigure = ''
    mkdir -pv $out/share/X11/xorg.conf.d
    configureFlagsArray+=(
      "--with-xorg-module-dir=$out/lib/xorg/modules"
      "--with-sdkdir=$out/include/xorg"
      "--with-xorg-conf-dir=$out/share/X11/xorg.conf.d"
    )
  '';

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      failEarly = true;
      pgpsigUrls = map (n: "${n}.sig") src.urls;
      pgpKeyFingerprint = "9A12 ECCC 5383 CA2A F5B4  2CDC A6DC 6691 1B21 27D5";
    };
  };

  meta = with lib; {
    description = "Wacom digitizer driver for X11";
    homepage = http://linuxwacom.sourceforge.net;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

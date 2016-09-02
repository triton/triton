{ stdenv
, fetchurl

, file
, ncurses
, systemd_lib
, xorg
}:

stdenv.mkDerivation rec {
  name = "xf86-input-wacom-0.33.0";

  src = fetchurl {
    url = "mirror://sourceforge/linuxwacom/${name}.tar.bz2";
    multihash = "QmWVD3PFeRbH9dYbhWDzkWiSM58tt5V9fJwbUYVBdtPAKK";
    hashOutput = false;
    sha256 = "24eef830744a388795a318ef743f19c451e394d9ef1332e98e2d54810a70f8e0";
  };

  buildInputs = [
    ncurses
    systemd_lib
    xorg.inputproto
    xorg.kbproto
    xorg.libX11
    xorg.libXext
    xorg.libXi
    xorg.libXinerama
    xorg.libXrandr
    xorg.libXrender
    xorg.pixman
    xorg.randrproto
    xorg.xorgserver
    xorg.xproto
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

  meta = with stdenv.lib; {
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

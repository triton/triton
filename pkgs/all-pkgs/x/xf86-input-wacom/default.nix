{ stdenv
, fetchurl
, lib

, file
, inputproto
, kbproto
, libx11
, libxext
, libxi
, libxinerama
, libxrandr
, libxrender
, ncurses
, randrproto
, systemd_lib
, xorg
, xorg-server
, xproto
}:

stdenv.mkDerivation rec {
  name = "xf86-input-wacom-0.36.0";

  src = fetchurl {
    url = "mirror://sourceforge/linuxwacom/${name}.tar.bz2";
    multihash = "QmQfPzFwv15U2sEA193SZdQdfmxouboKSTXg2p97hFtCnk";
    hashOutput = false;
    sha256 = "eae7c5d2872b1433c8d679bb42b00213403eb2a0544c514f4df2b586284c23f6";
  };

  buildInputs = [
    ncurses
    systemd_lib
    inputproto
    kbproto
    libx11
    libxext
    libxi
    libxinerama
    libxrandr
    libxrender
    xorg.pixman
    randrproto
    xorg-server
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

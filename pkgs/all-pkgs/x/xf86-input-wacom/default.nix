{ stdenv
, fetchurl
, lib

, file
, libpciaccess
, libx11
, libxext
, libxi
, libxinerama
, libxrandr
, libxrender
, ncurses
, systemd_lib
, xorg
, xorg-server
, xorgproto
}:

stdenv.mkDerivation rec {
  name = "xf86-input-wacom-0.36.1";

  src = fetchurl {
    url = "https://github.com/linuxwacom/xf86-input-wacom/releases/download/"
      + "${name}/${name}.tar.bz2";
    hashOutput = false;
    sha256 = "3206b92a4ed1fece07438a85405c748b9ed62cf0f0c3df845a2ce695d5463e09";
  };

  buildInputs = [
    ncurses
    systemd_lib
    libpciaccess
    libx11
    libxext
    libxi
    libxinerama
    libxrandr
    libxrender
    xorg.pixman
    xorg-server
    xorgproto
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
    homepage = https://github.com/linuxwacom/xf86-input-wacom;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

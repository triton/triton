{ stdenv
, autoreconfHook
, fetchzip
, lib
, util-macros

, cairo
#, intel-gpu-tools
, libdrm
, libpciaccess
, libpng
, libx11
, libxcb
, libxcursor
, libxdamage
, libxext
, libxfixes
, libxfont2
, libxrandr
, libxrender
, libxscrnsaver
, libxshmfence
, libxtst
, libxv
#, libxvmc
#, pixman
, systemd_lib
#, xcb-util
, xorg
, xorg-server
, xorgproto
}:

let
  rev = "37a682aa8a420a75a920e0fa7cf8659f834ed60f";
in
stdenv.mkDerivation {
  name = "xf86-video-intel-2017-11-09";

  src = fetchzip {
    version = 3;
    url = "https://cgit.freedesktop.org/xorg/driver/xf86-video-intel/snapshot/"
      + "${rev}.tar.gz";
    sha256 = "895dd96ce1321b577acb28abbfdbcc5090d76ee7f0fcbf4f66f9feb20557a68c";
  };

  nativeBuildInputs = [
    autoreconfHook
    util-macros
  ];

  buildInputs = [
    cairo
    #intel-gpu-tools
    xorg.intelgputools
    libdrm
    libpciaccess
    libpng
    libx11
    libxcb
    libxcursor
    libxdamage
    libxext
    libxfixes
    libxfont2
    libxrandr
    libxrender
    libxscrnsaver
    libxshmfence
    libxtst
    libxv
    #libxvmc
    xorg.libXvMC
    xorg.pixman
    systemd_lib
    #xcb-util
    xorg.xcbutil
    xorg-server
    xorgproto
  ];

  configureFlags = [
    "--enable-selective-werror"
    "--disable-strict-compilation"
    "--enable-backlight"
    "--enable-backlight-helper"
    "--disable-gen4asm"
    "--enable-udev"
    "--enable-tools"
    "--enable-dri"
    "--disable-dri1"
    "--enable-dri2"
    "--enable-dri3"
    "--disable-xvmc"
    "--enable-kms"
    "--enable-ums"
    "--disable-kms-only"
    "--disable-ums-only"
    "--enable-sna"
    "--enable-uxa"
    "--disable-xaa"
    "--disable-dga"
    "--enable-tear-free"
    "--disable-create2"
    "--disable-async-swap"
    "--disable-debug"
    "--disable-valgrind"
    "--without-gen4asm"
    "--with-default-dri=2"
    "--with-default-accel=sna"
  ];

  bindnow = false;

  meta = with lib; {
    description = "Intel video driver";
    homepage = https://cgit.freedesktop.org/xorg/driver/xf86-video-intel/;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

{ stdenv
, bison
, fetchurl
, flex
, lib
, makeWrapper
, util-macros

, audit_lib
, bigreqsproto
, compositeproto
, damageproto
, dbus
, dmxproto
, dri2proto
, dri3proto
, fixesproto
, fontsproto
, glproto
, inputproto
, kbproto
, libdmx
, libdrm
, libepoxy
#, libpciaccess
, libselinux
, libunwind
, libx11
, libxau
#, libxaw
, libxcb
, libxdmcp
, libxext
, libxfixes
, libxfont2
, libxi
, libxkbfile
#, libxmu
#, libxpm
, libxrender
, libxres
#, libxshmfence
, libxt
, libxtst
, opengl-dummy
, openssl
#, pixman
, presentproto
, randrproto
, recordproto
, renderproto
, resourceproto
, scrnsaverproto
, systemd_lib
, tslib
, videoproto
, wayland
, wayland-protocols
, windowswmproto
#, xcb-util
#, xcbutilwm
#, xcbutilimage
#, xcbutilkeysyms
#, xcbutilrenderutil
, xcmiscproto
, xextproto
, xf86bigfontproto
, xf86dgaproto
, xf86driproto
, xf86vidmodeproto
, xineramaproto
, xorg
, xproto
, xtrans
}:

stdenv.mkDerivation rec {
  name = "xorg-server-1.19.5";

  src = fetchurl {
    url = "mirror://xorg/individual/xserver/${name}.tar.bz2";
    hashOutput = false;
    sha256 = "18fffa8eb93d06d2800d06321fc0df4d357684d8d714315a66d8dfa7df251447";
  };

  nativeBuildInputs = [
    bison
    flex
    makeWrapper
    util-macros
  ];

  buildInputs = [
    audit_lib
    bigreqsproto
    compositeproto
    damageproto
    dbus
    dmxproto
    dri2proto
    dri3proto
    fixesproto
    fontsproto
    glproto
    inputproto
    kbproto
    libdmx
    libdrm
    libepoxy
    xorg.libpciaccess
    libselinux
    libunwind
    libx11
    libxau
    xorg.libXaw
    libxcb
    libxdmcp
    libxext
    libxfixes
    libxfont2
    libxi
    libxkbfile
    xorg.libXmu
    xorg.libXpm
    libxrender
    libxres
    xorg.libxshmfence
    libxt
    libxtst
    opengl-dummy
    openssl
    xorg.pixman
    presentproto
    randrproto
    recordproto
    renderproto
    resourceproto
    scrnsaverproto
    systemd_lib
    tslib
    videoproto
    wayland
    wayland-protocols
    windowswmproto
    xorg.xcbutil
    xorg.xcbutilwm
    xorg.xcbutilimage
    xorg.xcbutilkeysyms
    xorg.xcbutilrenderutil
    xcmiscproto
    xextproto
    xf86bigfontproto
    xf86dgaproto
    xf86driproto
    xf86vidmodeproto
    xineramaproto
    xproto
    xtrans
  ];

  patches = [
    ../xorg/xorgserver-xkbcomp-path.patch  # FIXME: use fetchTritonPatch
  ];

  configureFlags = [
    "--enable-selective-werror"
    "--disable-strict-compilation"
    "--disable-docs"
    "--disable-devel-docs"
    "--disable-unit-tests"
    "--enable-largefile"
    "--disable-debug"
    "--disable-listen-tcp"  # ???
    "--enable-listen-unix"
    "--enable-listen-local"
    "--disable-sparkle"  # macOS
    "--disable-visibility"
    "--enable-composite"
    "--enable-mitshm"
    "--enable-xres"
    "--enable-record"
    "--enable-xv"
    "--enable-xvmc"
    "--enable-dga"
    "--enable-screensaver"
    "--enable-xdmcp"
    "--enable-xdm-auth-1"
    "--enable-glx"
    "--enable-dri"
    "--enable-dri2"
    "--enable-dri3"
    "--enable-present"
    "--enable-xinerama"
    "--enable-xf86vidmode"
    "--enable-xace"
    "--enable-xselinux"
    "--enable-xcsecurity"
    "--enable-tslib"
    "--enable-dbe"
    "--enable-xf86bigfont"
    "--enable-dpms"
    "--enable-config-udev"
    "--enable-config-udev-kms"
    "--disable-config-hal"
    #"--enable-config-wscons"
    "--enable-xfree86-utils"
    "--enable-vgahw"
    "--enable-vbe"
    "--enable-int10-module"
    "--enable-windowswm"
    #"--enable-windowsdri"
    "--enable-libdrm"
    "--enable-clientids"
    "--enable-pciaccess"
    "--enable-linux-acpi"
    "--enable-linux-apm"
    "--enable-systemd-logind"
    "--enable-suid-wrapper"
    "--enable-xorg"
    "--enable-dmx"
    "--enable-xvfb"
    "--enable-xnest"
    "--disable-xquartz"  # macOS
    "--enable-xwayland"
    "--disable-standalone-xpbproxy"  # macOS
    "--disable-xwin"  # Windows
    "--enable-glamor"
    "--enable-kdrive"
    "--enable-xephyr"
    "--enable-xfake"
    "--enable-xfbdev"
    "--enable-kdrive-kbd"
    "--enable-kdrive-mouse"
    "--enable-kdrive-evdev"
    "--enable-libunwind"
    "--enable-xshmfence"
    "--disable-install-setuid"  # Can't setuid in a nix-builder
    "--enable-unix-transport"
    "--disable-tcp-transport"  # ???
    "--enable-ipv6"
    "--enable-local-transport"
    "--enable-secure-rpc"
    "--enable-input-thread"
    "--enable-xtrans-send-fds"

    "--without-doxygen"
    "--without-xmlto"
    "--without-fop"
    "--without-xsltproc"
    "--without-dtrace"
      # --with-int10=BACKEND
      # --with-module-dir=DIR
      # --with-log-dir=DIR
      # --with-builderstring=BUILDERSTRING
      # --with-fallback-input-driver=$FALLBACK_INPUT_DRIVER
      # --with-fontrootdir=DIR
      # --with-fontmiscdir=DIR
      # --with-fontotfdir=DIR
      # --with-fontttfdir=DIR
      # --with-fonttype1dir=DIR
      # --with-font75dpidir=DIR
      # --with-font100dpidir=DIR
    # There are only paths containing "${prefix}" and no fonts.
    "--with-default-font-path="
      # --with-xkb-path=PATH
      # --with-xkb-output=PATH
      # --with-default-xkb-rules=RULES
      # --with-default-xkb-model=MODEL
      # --with-default-xkb-layout=LAYOUT
      # --with-default-xkb-variant=VARIANT
      # --with-default-xkb-options=OPTIONS
      # --with-serverconfig-path=PATH
    "--with-systemd-daemon"
      # --with-shared-memory-dir=PATH
      # --with-xkb-bin-directory=DIR
    "--with-sha1=libcrypto"
  ];

  postInstall = ''
    rm -fr $out/share/X11/xkb/compiled
    ln -s /var/tmp $out/share/X11/xkb/compiled

    wrapProgram $out/bin/Xephyr \
      --set XKB_BINDIR "${xorg.xkbcomp}/bin" \
      --add-flags "-xkbdir ${xorg.xkeyboardconfig}/share/X11/xkb"
    wrapProgram $out/bin/Xvfb \
      --set XKB_BINDIR "${xorg.xkbcomp}/bin" \
      --set XORG_DRI_DRIVER_PATH ${opengl-dummy.driverSearchPath}/lib/dri \
      --add-flags "-xkbdir ${xorg.xkeyboardconfig}/share/X11/xkb"
  '';

  bindnow = false;

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      pgpsigUrls = map (n: "${n}.sig") src.urls;
      pgpKeyFingerprints = [
        # Adam Jackson
        "995E D5C8 A613 8EB0 961F  1847 4C09 DD83 CAAA 50B2"
      ];
      failEarly = true;
    };
  };

  meta = with lib; {
    description = "";
    homepage = https://xorg.freedesktop.org;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

{ stdenv
, bison
, fetchurl
, flex
, lib
, makeWrapper
, meson
, ninja
, util-macros

, audit_lib
, dbus
, libbsd
, libdmx
, libdrm
, libepoxy
#, libpciaccess
, libselinux
, libtirpc
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
, nettle
, opengl-dummy
, openssl
#, pixman
, systemd_lib
, tslib
, wayland
, wayland-protocols
#, xcb-util
#, xcbutilwm
#, xcbutilimage
#, xcbutilkeysyms
#, xcbutilrenderutil
, xorg
, xorgproto
, xtrans

, channel
}:

assert opengl-dummy.glx;

let
  inherit (stdenv)
    targetSystem;

  inherit (lib)
    boolTf
    elem
    optionals
    optionalString
    platforms
    versionAtLeast;

  sources = {
    "1.19" = {
      version = "1.19.6";
      sha256 = "a732502f1db000cf36a376cd0c010ffdbf32ecdd7f1fa08ba7f5bdf9601cc197";
    };
    "1.20" = {
      version = "1.19.99.901";
      sha256 = "3654e69e19426d9738381abbe0c325082be42971535eb791fb3604f60499a36e";
    };
  };
  source = sources."${channel}";
in
stdenv.mkDerivation rec {
  name = "xorg-server-${source.version}";

  src = fetchurl {
    url = "mirror://xorg/individual/xserver/${name}.tar.bz2";
    hashOutput = false;
    inherit (source) sha256;
  };

  nativeBuildInputs = [
    bison
    flex
    makeWrapper
    util-macros
  ] ++ optionals (versionAtLeast channel "1.20") [
    meson
    ninja
  ];

  # xkbcomp
  buildInputs = [
    audit_lib
    dbus
    libbsd
    libdmx
    libdrm
    libepoxy
    xorg.libpciaccess
    libselinux
    libtirpc
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
    nettle
    opengl-dummy
    openssl
    xorg.pixman
    systemd_lib
    tslib
    wayland
    wayland-protocols
    xorg.xcbutil
    xorg.xcbutilwm
    xorg.xcbutilimage
    xorg.xcbutilkeysyms
    xorg.xcbutilrenderutil
    xorg.xkbcomp
    xorgproto
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
    # There are only paths containing "${prefix}" and no fonts.
    "--with-default-font-path="
    "--with-systemd-daemon"
    "--with-sha1=libcrypto"
  ];

  mesonFlags = [
    "-Dxorg=true"
    "-Dxephyr=true"
    "-Dxwayland=true"
    "-Dglamor=true"
    "-Dxnest=true"
    "-Ddmx=true"
    "-Dxvfb=true"  # FIXME
    "-Dxwin=false"  # Windows
    "-Dglx=true"
    "-Dxdmcp=true"
    "-Dxdm-auth-1=true"
    "-Dsecure-rpc=true"
    "-Dipv6=true"
    "-Dint10=auto"
    "-Dpciaccess=true"
    "-Dudev=true"
    "-Dhal=false"
    "-Dsystemd_logind=true"
    "-Dvbe=true"
    "-Dvgahw=true"
    "-Ddpms=true"
    "-Dxf86bigfont=true"
    "-Dscreensaver=true"
    "-Dxres=true"
    "-Dxace=true"
    "-Dxinerama=true"
    "-Dxcsecurity=true"
    "-Dxv=true"
    "-Dxvmc=true"
    "-Ddga=true"
    "-Dlinux_apm=${boolTf (elem targetSystem platforms.linux)}"
    "-Dlinux_acpi=${boolTf (elem targetSystem platforms.linux)}"
    "-Dmitshm=true"
    "-Ddri1=true"
    "-Ddri2=true"
    "-Ddri3=true"
  ];

  postPatch = optionalString (versionAtLeast channel "1.20") ''
    # Xwin is an unconditional dependency.
    sed -i include/meson.build \
      -e '/xwin-config.h/,+2 d'

    # Remove tests that are broken in the release tarball.
    sed -i test/meson.build \
      -e '/bigreq/d' \
      -e '/sync/d'
  '';

  postInstall = ''
    rm -fr $out/share/X11/xkb/compiled
    ###ln -s /var/tmp $out/share/X11/xkb/compiled  # FIXME

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
        "DD38 563A 8A82 2453 7D1F  90E4 5B8A 2D50 A0EC D0D3"
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

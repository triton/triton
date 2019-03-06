{ stdenv
, bison
, fetchurl
, flex
, lib
, makeWrapper
, meson
, ninja

, dbus
, egl-wayland
#, fontutil
, libbsd
, libdmx
, libdrm
, libepoxy
, libpciaccess
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
, libxmu
#, libxpm
, libxrender
, libxres
, libxshmfence
, libxt
, libxtst
, nettle
, opengl-dummy
#, pixman
, systemd_lib
, wayland
, wayland-protocols
#, xcb-util
#, xcbutilwm
#, xcbutilimage
#, xcbutilkeysyms
#, xcbutilrenderutil
, xkbcomp
, xkeyboard-config
, xorg
, xorgproto
, xtrans

, channel
}:

assert opengl-dummy.glx;

let
  sources = {
    "1.20" = {
      version = "1.20.4";
      sha256 = "fe0fd493ebe93bfc56bede382fa204458ff5f636ea54d413a5d1bd58e19166ee";
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
    meson
    ninja
  ];

  buildInputs = [
    dbus
    egl-wayland
    xorg.fontutil
    libbsd
    libdmx
    libdrm
    libepoxy
    libpciaccess
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
    libxmu
    xorg.libXpm
    libxrender
    libxres
    libxshmfence
    libxt
    libxtst
    nettle
    opengl-dummy
    xorg.pixman
    systemd_lib
    wayland
    wayland-protocols
    xorg.xcbutil
    xorg.xcbutilwm
    xorg.xcbutilimage
    xorg.xcbutilkeysyms
    xorg.xcbutilrenderutil
    xkbcomp
    xorgproto
    xtrans
  ];

  patches = [
    ../xorg/xorgserver-xkbcomp-path.patch  # FIXME: use fetchTritonPatch
  ];

  mesonFlags = [
    "-Dxorg=true"
    "-Dxephyr=true"
    "-Dxwayland=true"
    "-Dglamor=true"
    "-Dxwayland_eglstream=true"
    "-Dxnest=true"
    "-Dxvfb=true"
    "-Dxwin=false"  # Windows
    "-Dipv6=true"
    "-Dinput_thread=true"
    "-Dhal=false"
    "-Dsystemd_logind=true"
    "-Dvbe=true"
    "-Dvgahw=true"
    "-Dxselinux=true"
    "-Dxcsecurity=true"
    "-Ddga=true"
    "-Dmitshm=true"
    "-Dagp=false"
    "-Ddri1=true"
    "-Ddri2=true"
    "-Ddri3=true"
  ];

  postPatch = ''
    # Don't build tests
    grep -q "subdir('test')" meson.build
    sed -i "/subdir('test')/d" meson.build

    # Fix missing file
    ! test -e include/xwayland-config.h.meson.in
    grep -q 'xwayland-config.h.meson.in' include/meson.build
    cat ${./xwayland-config.h.meson.in} > include/xwayland-config.h.meson.in
  '';

  postInstall = ''
    rm -fr $out/share/X11/xkb/compiled
    ###ln -s /var/tmp $out/share/X11/xkb/compiled  # FIXME

    wrapProgram $out/bin/Xephyr \
      --set XKB_BINDIR "${xkbcomp}/bin" \
      --add-flags "-xkbdir ${xkeyboard-config}/share/X11/xkb"
    wrapProgram $out/bin/Xvfb \
      --set XKB_BINDIR "${xkbcomp}/bin" \
      --set XORG_DRI_DRIVER_PATH ${opengl-dummy.driverSearchPath}/lib/dri \
      --add-flags "-xkbdir ${xkeyboard-config}/share/X11/xkb"
  '';

  bindnow = false;

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      fullOpts = {
        pgpsigUrls = map (n: "${n}.sig") src.urls;
        pgpKeyFingerprints = [
          # Adam Jackson
          "DD38 563A 8A82 2453 7D1F  90E4 5B8A 2D50 A0EC D0D3"
          "995E D5C8 A613 8EB0 961F  1847 4C09 DD83 CAAA 50B2"
        ];
      };
      failEarly = true;
    };
  };

  meta = with lib; {
    description = "";
    homepage = https://xorg.freedesktop.org;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}


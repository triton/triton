{ stdenv
, bison
, fetchurl
, flex
, lib
, meson
, ninja
, util-macros

, dbus
, egl-wayland
#, fontutil
, libbsd
, libdmx
, libdrm
, libepoxy
, libpciaccess
, libtirpc
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
      version = "1.20.0";
      sha256 = "9d967d185f05709274ee0c4f861a4672463986e550ca05725ce27974f550d3e6";
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
    meson
    ninja
  ];

  buildInputs = [
    dbus
    egl-wayland
    #fontutil
    xorg.fontutil
    libbsd
    libdmx
    libdrm
    libepoxy
    libpciaccess
    libtirpc
    libx11
    libxau
    #libxaw
    xorg.libXaw
    libxcb
    libxdmcp
    libxext
    libxfixes
    libxfont2
    libxi
    libxkbfile
    libxmu
    #libxpm
    xorg.libXpm
    libxrender
    libxres
    libxshmfence
    libxt
    libxtst
    nettle
    opengl-dummy
    #pixman
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

  postPatch = ''
    # Don't build tests
    grep -q "subdir('test')" meson.build
    sed -i "/subdir('test')/d" meson.build
  
    # Fix missing file
    ! test -e include/xwayland-config.h.meson.in
    grep -q 'xwayland-config.h.meson.in' include/meson.build
    cat ${./xwayland-config.h.meson.in} >include/xwayland-config.h.meson.in
  '';

  mesonFlags = [
    "-Dxephyr=true"
    "-Ddmx=true"
    "-Dxf86bigfont=true"
    "-Dxcsecurity=true"
  ];

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
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

{ stdenv
, cmake
, fetchurl
, lib
, ninja

, alsa-lib
, dbus
, fixesproto
, glib
, ibus
, inputproto
, kbproto
, libice
, libdrm
, libsamplerate
#, libusb
, libx11
, libxcursor
, libxext
, libxfixes
, libxi
, libxinerama
, libxkbcommon
, libxrandr
, libxrender
, libxscrnsaver
#, libxxf86vm
, opengl-dummy
, pulseaudio_lib
, randrproto
, renderproto
, scrnsaverproto
, systemd_lib
, tslib
#, vulkan-headers
, wayland
, wayland-protocols
, xextproto
, xf86vidmodeproto
, xorg
, xproto

, x11 ? true
}:

# TODO: remove unnecessary dependencies
# FIXME: USBHID support

let
  inherit (lib)
    boolOn;

  version = "2.0.6";
in
stdenv.mkDerivation rec {
  name = "SDL-${version}";

  src = fetchurl {
    url = "https://www.libsdl.org/release/SDL2-${version}.tar.gz";
    hashOutput = false;
    sha256 = "03658b5660d16d7b31263a691e058ed37acdab155d68dabbad79998fb552c5df";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  buildInputs = [
    alsa-lib
    dbus
    fixesproto
    glib  # ???: possibly not propagated via pkgconfig correctly
    ibus
    inputproto
    kbproto
    libdrm
    libice
    libsamplerate
    #libusb
    libx11
    libxcursor
    libxext
    libxfixes
    libxi
    libxinerama
    libxkbcommon
    libxrandr
    libxrender
    libxscrnsaver
    #libxxf86vm
    xorg.libXxf86vm
    opengl-dummy
    pulseaudio_lib
    randrproto
    renderproto
    scrnsaverproto
    systemd_lib
    tslib
    #vulkan-headers
    wayland
    wayland-protocols
    xextproto
    xf86vidmodeproto
    xproto

    randrproto
    renderproto
  ];

  cmakeFlags = [
    "-DLIBC=ON"
    #GCC_ATOMICS
    "-DASSEMBLY=ON"
    "-DSSEMATH=ON"
    "-DMMX=ON"
    "-D3DNOW=ON"
    "-DSSE=ON"
    "-DSSE2=ON"
    "-DSSE3=ON"
    "-DALTIVEC=ON"
    "-DDISKAUDIO=ON"
    "-DDUMMYAUDIO=ON"
    "-DVIDEO_DIRECTFB=OFF"
    #"DIRECTFB_SHARED"
    "-DVIDEO_DUMMY=ON"
    "-DVIDEO_OPENGL=${boolOn (opengl-dummy != null)}"
    "-DVIDEO_OPENGLES=${boolOn (opengl-dummy.glesv1 || opengl-dummy.glesv2)}"
    "-DPTHREADS=ON"
    #"PTHREADS_SEM"
    "-DSDL_DLOPEN=ON"  # FIXME: only for dynamic linking
    "-DOSS=OFF"
    "-DALSA=ON"
    #"-DALSA_SHARED=ON"
    #"JACK"  # TODO
    #"JACK_SHARED"
    #"ESD"  # TODO
    #"ESD_SHARED"
    "-DPULSEAUDIO=ON"
    #"-DPULSEAUDIO_SHARED=ON"
    #"ARTS"  $ TODO
    #"ARTS_SHARED"
    #"NAS"  # TODO
    #"NAS_SHARED"
    #"SNDIO"  # TODO
    #"FUSIONSOUND"  # TODO
    #"FUSIONSOUND_SHARED"
    "-DLIBSAMPLERATE=ON"
    #"-DLIBSAMPLERATE_SHARED=ON"
    "-DRPATH=ON"
    #"CLOCK_GETTIME"
    "-DINPUT_TSLIB=ON"
    "-DVIDEO_X11=ON"
    "-DVIDEO_WAYLAND=ON"
    #"-DWAYLAND_SHARED=ON"
    #"VIDEO_WAYLAND_QT_TOUCH"  # TODO
    "-DVIDEO_MIR=OFF"
    #"-DMIR_SHARED=OFF"
    "-DVIDEO_RPI=OFF"  # Raspberry Pi
    #"-DX11_SHARED=${boolOn x11}"
    "-DVIDEO_X11_XCURSOR=${boolOn x11}"
    "-DVIDEO_X11_XINERAMA=${boolOn x11}"
    "-DVIDEO_X11_XINPUT=${boolOn x11}"
    "-DVIDEO_X11_XRANDR=${boolOn x11}"
    "-DVIDEO_X11_XSCRNSAVER=${boolOn x11}"
    "-DVIDEO_X11_XSHAPE=${boolOn x11}"
    "-DVIDEO_X11_XVM=${boolOn x11}"
    "-DVIDEO_COCOA=OFF"  # macOS
    "-DDIRECTX=OFF"  # Windows
    #"RENDER_D3D"
    #"VIDEO_VIVANTE"
    "-DVIDEO_VULKAN=ON"  # FIXME
    "-DVIDEO_KMSDRM=ON"
    #"KMSDRM_SHARED"
    "-DSDL_SHARED=ON"
    "-DSDL_STATIC=OFF"
    #"SDL_STATIC_PIC"  # TODO
  ];

  # NIX_CFLAGS_COMPILE = [
  #   "-I${libusb}/include/libusb-1.0/"
  # ];

  # There is a build bug with `--disable-static`
  dontDisableStatic = true;

  postInstall = ''
    find $out/lib -name \*.a -delete
  '';

  passthru = {
    srcVerification = fetchurl rec {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      pgpsigUrls = map (n: "${n}.sig") src.urls;
      pgpKeyFingerprint = "1528 635D 8053 A57F 77D1  E086 30A5 9377 A776 3BE6";
      failEarly = true;
    };
  };

  meta = with lib; {
    description = "Simple Direct Media Layer";
    homepage = http://www.libsdl.org;
    license = licenses.zlib;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

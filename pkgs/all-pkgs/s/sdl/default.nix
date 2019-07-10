{ stdenv
, cmake
, fetchurl
, lib
, ninja

, alsa-lib
, dbus
, glib
, ibus
, libice
, libdrm
, libsamplerate
#, libusb
, libx11
, libxcb
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
, systemd_lib
, tslib
#, vulkan-headers  # FIXME: unvendor headers
, wayland
, wayland-protocols
, xorg
, xorgproto

, x11 ? true
}:

# TODO: remove unnecessary dependencies
# FIXME: USBHID support

let
  version = "2.0.8";
in
stdenv.mkDerivation rec {
  name = "SDL-${version}";

  src = fetchurl {
    url = "https://www.libsdl.org/release/SDL2-${version}.tar.gz";
    multihash = "Qme3L6c5NYSv8eafYPJtBLecqJEJ86Etosk2MsXry7wd6j";
    hashOutput = false;
    sha256 = "edc77c57308661d576e843344d8638e025a7818bff73f8fbfab09c3c5fd092ec";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  buildInputs = [
    alsa-lib
    dbus
    glib  # ???: possibly not propagated via pkgconfig correctly
    ibus
    libdrm
    libice
    libsamplerate
    #libusb
    libx11
    libxcb
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
    systemd_lib
    tslib
    #vulkan-headers
    wayland
    wayland-protocols
    xorgproto
  ];

  cmakeFlags = [
    "-DSSEMATH=ON"
    "-DSDL_DLOPEN=ON"  # FIXME: only for dynamic linking
    "-DOSS=OFF"
    #"JACK"  # TODO
    "-DESD=OFF"
    "-DLIBSAMPLERATE=ON"
    "-DSDL_SHARED=ON"
    "-DSDL_STATIC=OFF"
  ];

  # NIX_CFLAGS_COMPILE = [
  #   "-I${libusb}/include/libusb-1.0/"
  # ];

  # There is a build bug with `--disable-static`
  disableStatic = false;

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

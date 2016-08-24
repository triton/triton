{ stdenv
, fetchurl
, gnum4
, patchelf

, gdk-pixbuf_unwrapped
, glib
, gtk_2
, gtk_3
, jansson
, libvdpau
, mesa_noglu
, pango
, xorg

, channel
}:

let
  inherit (stdenv.lib)
    makeSearchPath;

  source = (import ./sources.nix { })."${channel}";
in
stdenv.mkDerivation rec {
  name = "nvidia-settings-${source.version}";

  src = fetchurl {
    url = "http://http.download.nvidia.com/XFree86/nvidia-settings/"
      + "nvidia-settings-370.23.tar.bz2";
    inherit (source) sha256;
  };

  nativeBuildInputs = [
    gnum4
    patchelf
  ];

  buildInputs = [
    gdk-pixbuf_unwrapped
    glib
    gtk_2
    gtk_3
    jansson
    libvdpau
    mesa_noglu
    pango
    xorg.libX11
    xorg.libXext
    xorg.libXrandr
    xorg.libXrender
    xorg.libXv
    xorg.libXxf86vm
    xorg.randrproto
    xorg.renderproto
    xorg.videoproto
    xorg.xf86vidmodeproto
    xorg.xproto
    xorg.xextproto
  ];

  postPatch = /* libXv is normally loaded at runtime via LD_LIBRARY_PATH */ ''
    sed -i src/libXNVCtrlAttributes/NvCtrlAttributesXv.c \
      -e 's,"libXv.so.1","${xorg.libXv}/lib/libXv.so.1",'
  '';

  preBuild = ''
    makeFlagsArray+=("PREFIX=$out")
  '';

  makeFlags = [
    "GTK3_AVAILABLE=1"
    "NV_VERBOSE=1"
    "NV_USE_BUNDLED_LIBJANSSON=0"
    # TODO: package nvidia-gpu-deployment-kit
    "NVML_AVAILABLE=0"
  ];

  meta = with stdenv.lib; {
    description = "NVIDIA driver control panel";
    homepage = http://www.nvidia.com/;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

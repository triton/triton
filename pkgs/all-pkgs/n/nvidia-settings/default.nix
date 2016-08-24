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
, nvidia-gpu-deployment-kit
, pango
, xorg

, channel
}:

let
  inherit (stdenv.lib)
    bool01
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
    nvidia-gpu-deployment-kit
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
    "NVML_AVAILABLE=${bool01 (nvidia-gpu-deployment-kit != null)}"
  ];

  postInstall = /* NVIDIA Settings .desktop entry */ ''
    install -D -m 644 -v 'doc/nvidia-settings.desktop' \
      "$out/share/applications/nvidia-settings.desktop"
    sed -i "$out/share/applications/nvidia-settings.desktop" \
      -e "s,__UTILS_PATH__,$out/bin," \
      -e "s,__PIXMAP_PATH__,$out/share/pixmaps,"
  '' + /* NVIDIA Settings icon */ ''
    install -D -m644 -v 'doc/nvidia-settings.png' \
      "$out/share/pixmaps/nvidia-settings.png"
  '';

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

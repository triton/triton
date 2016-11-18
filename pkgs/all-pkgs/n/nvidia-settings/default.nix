{ stdenv
, fetchurl
, gnum4
, makeWrapper

, gdk-pixbuf_unwrapped
, glib
, gtk_2
, gtk_3
, jansson
, libvdpau
, mesa_noglu
, pango
, xorg
}:

let
  inherit (stdenv.lib)
    bool01;

    version = "375.20";
in
stdenv.mkDerivation rec {
  name = "nvidia-settings-${version}";

  src = fetchurl {
    url = "http://http.download.nvidia.com/XFree86/nvidia-settings/"
      + "nvidia-settings-${version}.tar.bz2";
    sha256 = "40cd293e79bda131147187f281578e2b1f887c05bee78f671bde329af4956ada";
  };

  nativeBuildInputs = [
    gnum4
    makeWrapper
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
  '' + # FIXME: nvidia-settings should depend on the nvidia-drivers directly
       #        for this file rather than using /etc.
    /* Fix nvidia-application-profiles-key-documentation loading */ ''
    sed -i src/gtk+-2.x/ctkappprofile.c  \
      -e "s,/usr/share,/etc,"
  '';

  preBuild = ''
    makeFlagsArray+=("PREFIX=$out")
  '';

  makeFlags = [
    "GTK3_AVAILABLE=1"
    "NV_VERBOSE=1"
    "NV_USE_BUNDLED_LIBJANSSON=0"
    "NVML_AVAILABLE=1"
  ];

  postBuild = /* Build libXNVCtrl */ ''
    #make -C src/ $makeFlags build-xnvctrl
  '';

  postInstall = /* NVIDIA Settings .desktop entry */ ''
    install -D -m644 -v 'doc/nvidia-settings.desktop' \
      "$out/share/applications/nvidia-settings.desktop"
    sed -i "$out/share/applications/nvidia-settings.desktop" \
      -e "s,__UTILS_PATH__,$out/bin," \
      -e "s,__PIXMAP_PATH__,$out/share/pixmaps,"
  '' + /* NVIDIA Settings icon */ ''
    install -D -m644 -v 'doc/nvidia-settings.png' \
      "$out/share/pixmaps/nvidia-settings.png"
  '' + /* Install libXNVCtrl */ ''
    #install -D -m644 -v 'src/libXNVCtrl/libXNVCtrl.so' \
    #  "$out/lib/libXNVCtrl.so"
  '';

  preFixup = ''
    wrapProgram $out/bin/nvidia-settings \
      --prefix LD_LIBRARY_PATH : "$out/lib"
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

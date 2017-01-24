{ stdenv
, fetchurl
, gnum4
, lib
, makeWrapper

, adwaita-icon-theme
, gdk-pixbuf
, glib
, gtk_2
, gtk_3
, jansson
, libvdpau
, mesa_noglu
, nvidia-drivers_latest
, pango
, xorg
}:

let
  version = "378.09";
in
stdenv.mkDerivation rec {
  name = "nvidia-settings-${version}";

  src = fetchurl {
    url = "http://http.download.nvidia.com/XFree86/nvidia-settings/"
      + "nvidia-settings-${version}.tar.bz2";
    sha256 = "1bfdb4d42f4afc83a51f63574c3ae70c5f36e4dab87fc8c23564fef62bbe53ba";
  };

  nativeBuildInputs = [
    gnum4
    makeWrapper
  ];

  buildInputs = [
    adwaita-icon-theme
    gdk-pixbuf
    glib
    gtk_2
    gtk_3
    jansson
    libvdpau
    mesa_noglu
    nvidia-drivers_latest
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
    xorg.xextproto
    xorg.xf86vidmodeproto
    xorg.xproto
  ];

  postPatch = /* libXv is normally loaded at runtime via LD_LIBRARY_PATH */ ''
    sed -i src/libXNVCtrlAttributes/NvCtrlAttributesXv.c \
      -e 's,"libXv.so.1","${xorg.libXv}/lib/libXv.so.1",'
  '' + /* Fix nvidia-application-profiles-key-documentation loading */ ''
    sed -i src/gtk+-2.x/ctkappprofile.c  \
      -e "s,/usr/share,${nvidia-drivers_latest}/share,"
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
      --prefix LD_LIBRARY_PATH : "$out/lib" \
      --set 'GDK_PIXBUF_MODULE_FILE' "$GDK_PIXBUF_MODULE_FILE" \
      --prefix 'XDG_DATA_DIRS' : "$XDG_ICON_DIRS"
  '';

  meta = with lib; {
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

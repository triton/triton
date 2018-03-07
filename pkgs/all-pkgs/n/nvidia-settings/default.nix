{ stdenv
, fetchurl
, gnum4
, lib
, makeWrapper

, adwaita-icon-theme
, dbus
, gdk-pixbuf
, glib
, gnome-themes-standard
, gtk_2
, gtk_3
, jansson
, libvdpau
, libx11
, libxext
, libxrandr
, libxrender
, libxv
, nvidia-drivers_latest
, opengl-dummy
, pango
, xorgproto
, xorg
}:

let
  version = "390.25";
in
stdenv.mkDerivation rec {
  name = "nvidia-settings-${version}";

  src = fetchurl {
    url = "mirror://nvidia/XFree86/nvidia-settings/"
      + "nvidia-settings-${version}.tar.bz2";
    sha256 = "c79bb974e3e716f3448088d72201bb9cfeec8d13ea8dbe5376439bf191c90bca";
  };

  nativeBuildInputs = [
    gnum4
    makeWrapper
  ];

  buildInputs = [
    adwaita-icon-theme
    dbus
    gdk-pixbuf
    glib
    gnome-themes-standard
    gtk_2
    gtk_3
    jansson
    libvdpau
    libx11
    libxext
    libxrandr
    libxrender
    libxv
    xorg.libXxf86vm
    nvidia-drivers_latest
    opengl-dummy
    pango
    xorgproto
  ];

  postPatch = /* libXv is normally loaded at runtime via LD_LIBRARY_PATH */ ''
    sed -i src/libXNVCtrlAttributes/NvCtrlAttributesXv.c \
      -e 's,"libXv.so.1","${libxv}/lib/libXv.so.1",'
  '' + /* Fix nvidia-application-profiles-key-documentation loading */ ''
    sed -i src/gtk+-2.x/ctkappprofile.c  \
      -e "s,/usr/share,${nvidia-drivers_latest}/share,"
  '';

  preBuild = ''
    makeFlagsArray+=("PREFIX=$out")
  '' + /* Build libXNVCtrl */ ''
    make -C src/ $makeFlags build-xnvctrl
  '';

  makeFlags = [
    "GTK3_AVAILABLE=1"
    "NV_VERBOSE=1"
    "NV_USE_BUNDLED_LIBJANSSON=0"
    "NVML_AVAILABLE=1"
  ];

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
    install -D -m644 -v 'src/libXNVCtrl/NVCtrl.h' \
      "$out/include/NVCtrl/NVCtrl.h"
    install -D -m644 -v 'src/libXNVCtrl/nv_control.h' \
      "$out/include/NVCtrl/nv_control.h"
    install -D -m644 -v 'src/libXNVCtrl/libXNVCtrl.a' \
      "$out/lib/libXNVCtrl.a"
  '';

  preFixup = ''
    wrapProgram $out/bin/nvidia-settings \
      --prefix LD_LIBRARY_PATH : "$out/lib" \
      --set 'GDK_PIXBUF_MODULE_FILE' "${gdk-pixbuf.loaders.cache}" \
      --run "$DEFAULT_GTK2_RC_FILES" \
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

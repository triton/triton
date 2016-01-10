{ stdenv
, fetchurl
, yasm

, glib
, gst-plugins-bad
, gst-plugins-base
, gstreamer
, libdrm
, libva
, libvpx
, mesa
, udev
, wayland
, xorg
}:

with {
  inherit (stdenv.lib)
    enFlag
    optionalString;
};

stdenv.mkDerivation rec {
  name = "gstreamer-vaapi-0.7.0";

  src = fetchurl {
    url = "http://www.freedesktop.org/software/vaapi/releases/gstreamer-vaapi/"
        + "${name}.tar.bz2";
    sha256 = "14jal2g5mf8r59w8420ixl3kg50vcmy56446ncwd0xrizd6yms5b";
  };

  postPatch = optionalString (xorg.libX11 != null && mesa != null) ''
    # Fix broken variable replacement in pkg-config file
    sed -i pkgconfig/gstreamer-vaapi-glx.pc.in \
      -e "s,@LIBVA_GLX_PKGNAME@,$out/lib/pkgconfig/gstreamer-vaapi-glx-1.0.pc,"
  '';

  configureFlags = [
    "--enable-builtin-videoparsers"
    "--enable-builtin-codecparsers"
    (enFlag "builtin-libvpx" (libvpx == null) null)
    "--enable-encoders"
    (enFlag "drm" (libdrm != null) null)
    (enFlag "x11" (xorg.libX11 != null) null)
    (enFlag "glx" (xorg.libX11 != null && mesa != null) null)
    (enFlag "wayland" (wayland != null) null)
    (enFlag "egl" (wayland != null && mesa != null) null)
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
  ];

  preConfigure = ''
    # Wants to install gst-plugins-vaapi in the gstreamer prefix by default
    export GST_PLUGIN_PATH_1_0="$out/lib/gstreamer-1.0"
    mkdir -pv "$GST_PLUGIN_PATH_1_0"
  '';

  nativeBuildInputs = [
    yasm
  ];

  buildInputs = [
    glib
    gstreamer
    gst-plugins-bad
    gst-plugins-base
    libdrm
    libva
    libvpx
    mesa
    udev
    wayland
    xorg.libX11
    xorg.libXrandr
    xorg.libXrender
  ];

  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    description = "GStreamer VA-API hardware accelerated video processing";
    homepage = https://github.com/01org/gstreamer-vaapi;
    license = licenses.lgpl21Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];
  };
}

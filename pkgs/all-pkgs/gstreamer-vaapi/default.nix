{ stdenv
, fetchurl
, python3
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
  name = "gstreamer-vaapi-1.6.0";

  src = fetchurl {
    url = "https://gstreamer.freedesktop.org/src/gstreamer-vaapi/"
        + "${name}.tar.xz";
    sha256 = "1ljmafyn0kkil6x5iqvbkrvhinlj9l4zzdq4832cdwgm2b1p8i92";
  };

  nativeBuildInputs = [
    python3
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

  configureFlags = [
    "--disable-maintainer-mode"
    "--disable-fatal-warnings"
    "--disable-debug"
    "--enable-encoders"
    (enFlag "drm" (libdrm != null) null)
    (enFlag "x11" (xorg.libX11 != null) null)
    (enFlag "glx" (xorg.libX11 != null && mesa != null) null)
    (enFlag "wayland" (wayland != null) null)
    (enFlag "egl" (wayland != null && mesa != null) null)
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    "--enable-gobject-cast-checks"
    "--enable-glib-asserts"
  ];

  postInstall = "rm -rvf $out/share/gtk-doc";

  meta = with stdenv.lib; {
    description = "GStreamer VA-API hardware accelerated video processing";
    homepage = https://github.com/01org/gstreamer-vaapi;
    license = licenses.lgpl21Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}

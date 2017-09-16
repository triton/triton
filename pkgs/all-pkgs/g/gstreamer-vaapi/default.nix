{ stdenv
, fetchurl
, lib
, python3
, yasm

, glib
, gst-plugins-bad
, gst-plugins-base
, gstreamer
, libdrm
, libva
, libvpx
, libx11
, libxrandr
, libxrender
, mesa
, renderproto
, systemd_lib
, wayland
, xorg

, channel
}:

let
  inherit (lib)
    boolEn
    optionals;

  sources = {
    "1.12" = {
      version = "1.12.2";
      sha256 = "23c714e0474b3c7ae6ff8884aebf8503a1bc3ded335fa2d2b2ac31788466163a";
    };
  };

  source = sources."${channel}";
in
stdenv.mkDerivation rec {
  name = "gstreamer-vaapi-${source.version}";

  src = fetchurl rec {
    urls = map (n: "${n}/${name}.tar.xz") [
      "https://gstreamer.freedesktop.org/src/gstreamer-vaapi"
      "mirror://gnome/sources/gstreamer-vaapi/${channel}"
    ];
    hashOutput = false;
    inherit (source) sha256;
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
    libx11
    libxrandr
    libxrender
    mesa
    renderproto
    systemd_lib
    wayland
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--disable-fatal-warnings"
    "--disable-extra-checks"
    "--disable-debug"
    "--disable-examples"
    "--enable-encoders"
    "--${boolEn (libdrm != null)}-drm"
    "--${boolEn (libx11 != null)}-x11"
    "--${boolEn (libx11 != null && mesa != null)}-glx"
    "--${boolEn (wayland != null)}-wayland"
    "--${boolEn (wayland != null && mesa != null)}-egl"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    "--enable-gobject-cast-checks"
    "--disable-glib-asserts"
  ];

  NIX_CFLAGS_COMPILE = [
    "-I${gst-plugins-bad}/include/gstreamer-1.0"
    # FIXME: Gstreamer installs gstglconfig.h in the wrong location
    "-I${gst-plugins-bad}/lib/gstreamer-1.0/include"
  ];

  postInstall = "rm -rvf $out/share/gtk-doc";

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      sha256Urls = map (n: "${n}.sha256sum") src.urls;
      pgpsigUrls = map (n: "${n}.asc") src.urls;
      # Sebastian Dröge
      pgpKeyFingerprint = "7F4B C7CC 3CA0 6F97 336B  BFEB 0668 CC14 86C2 D7B5";
      failEarly = true;
    };
  };

  meta = with lib; {
    description = "GStreamer VA-API hardware accelerated video processing";
    homepage = https://github.com/01org/gstreamer-vaapi;
    license = licenses.lgpl21Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

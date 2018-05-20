{ stdenv
, fetchurl
, lib
, meson
, ninja

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
, opengl-dummy
, systemd_lib
, wayland
, xorgproto

, channel
}:

let
  inherit (lib)
    boolYn
    optionals;

  sources = {
    "1.14" = {
      version = "1.14.1";
      sha256 = "585c3ddb0c39220de0a33e5d0ed6196a108b8407ec3538d7c64617713b4434e8";
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
    meson
    ninja
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
    opengl-dummy
    systemd_lib
    wayland
    xorgproto
  ];

  mesonFlags = [
    "-Dwith_encoders=yes"
    "-Dwith_drm=${boolYn (libdrm != null)}"
    "-Dwith_x11=${boolYn (libx11 != null)}"
    "-Dwith_glx=${boolYn opengl-dummy.glx}"
    "-Dwith_wayland=${boolYn (opengl-dummy.egl && wayland != null)}"
    "-Dwith_egl=${boolYn opengl-dummy.egl}"
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
      pgpKeyFingerprints = [
        # Sebastian Dröge
        "7F4B C7CC 3CA0 6F97 336B  BFEB 0668 CC14 86C2 D7B5"
        # Tim-Philipp Müller
        "D637 032E 45B8 C658 5B94  5656 5D2E EE6F 6F34 9D7C"
      ];
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

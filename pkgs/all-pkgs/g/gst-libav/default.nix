{ stdenv
, fetchurl
, lib
, meson
, ninja

, ffmpeg
, glib
, gst-plugins-base
, gstreamer
, orc
, zlib

, channel
}:

let
  inherit (lib)
    boolEn
    boolWt;

  sources = {
    "1.14" = {
      version = "1.14.0";
      sha256 = "fb134b4d3e054746ef8b922ff157b0c7903d1fdd910708a45add66954da7ef89";
    };
  };

  source = sources."${channel}";
in
stdenv.mkDerivation rec {
  name = "gst-libav-${source.version}";

  src = fetchurl rec {
    urls = map (n: "${n}/${name}.tar.xz") [
      "https://gstreamer.freedesktop.org/src/gst-libav"
      "mirror://gnome/sources/gst-libav/${channel}"
    ];
    hashOutput = false;
    inherit (source) sha256;
  };

  nativeBuildInputs = [
    meson
    ninja
  ];

  buildInputs = [
    ffmpeg
    glib
    gst-plugins-base
    gstreamer
    orc
    zlib
  ];

  postUnpack = /* gst-libav vendors outdated ffmpeg sources */ ''
    pushd $srcRoot/gst-libs/ext/
      rm -rfv libav/
      tar -xf ${ffmpeg.src}
      mv -v ffmpeg-*/ libav/
    popd
  '';

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
    description = "FFmpeg based gstreamer plugin";
    homepage = http://gstreamer.freedesktop.org;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

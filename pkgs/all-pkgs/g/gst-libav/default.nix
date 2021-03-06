{ stdenv
, fetchurl
, lib
, meson
, ninja

, ffmpeg_3
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
      version = "1.14.2";
      sha256 = "8a351c39c5cfc2bbd31ca434ec4a290a730a26efbdea962fdd8306dce5c576de";
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
    ffmpeg_3
    glib
    gst-plugins-base
    gstreamer
    orc
    zlib
  ];

  postUnpack = /* gst-libav vendors outdated ffmpeg sources */ ''
    pushd $srcRoot/gst-libs/ext/
      rm -rfv libav/
      tar -xf ${ffmpeg_3.src}
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

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
    "1.12" = {
      version = "1.12.4";
      sha256 = "2a56aa5d2d8cd912f2bce17f174713d2c417ca298f1f9c28ee66d4aa1e1d9e62";
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
      mv ffmpeg-*/ libav/
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
      # Sebastian Dröge
      pgpKeyFingerprint = "7F4B C7CC 3CA0 6F97 336B  BFEB 0668 CC14 86C2 D7B5";
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

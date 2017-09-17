{ stdenv
, fetchurl
, gettext
, lib
, meson
, ninja

, a52dec
, amrnb
, amrwb
, glib
, gst-plugins-base
, gstreamer
, lame
, libcdio
, libdvdread
, libmpeg2
, mpg123
, orc
, x264

, channel
}:

let
  inherit (lib)
    boolEn;

  sources = {
    "1.12" = {
      version = "1.12.2";
      sha256 = "1cc3942bbf3ea87da3e35437d4e014e991b103db22a6174f62a98c89c3f5f466";
    };
  };

  source = sources."${channel}";
in
stdenv.mkDerivation rec {
  name = "gst-plugins-ugly-${source.version}";

  src = fetchurl rec {
    urls = map (n: "${n}/${name}.tar.xz") [
      "https://gstreamer.freedesktop.org/src/gst-plugins-ugly"
      "mirror://gnome/sources/gst-plugins-ugly/${channel}"
    ];
    hashOutput = false;
    inherit (source) sha256;
  };

  nativeBuildInputs = [
    gettext
    meson
    ninja
  ];

  buildInputs = [
    #a52dec  # FIXME
    amrnb
    amrwb
    glib
    gst-plugins-base
    gstreamer
    lame
    libcdio
    libdvdread
    libmpeg2
    mpg123
    orc
    x264
  ];

  mesonFlags = [
    # FIXME: add additional x264 libs for 10bpcc
    #"-Dx264_libraries"
  ];

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
    description = "Basepack of plugins for gstreamer";
    homepage = http://gstreamer.freedesktop.org;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

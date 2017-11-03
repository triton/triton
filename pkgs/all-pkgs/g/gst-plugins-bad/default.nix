{ stdenv
, fetchurl
, lib
, meson
, ninja
, python3

, bzip2
, chromaprint
, curl
, faac
, faad2
, flite
, game-music-emu
, glib
, gobject-introspection
, gsm
, gst-plugins-base
, gstreamer
, gtk_3
, ladspa-sdk
, libass
, libbs2b
, libmms
, libmodplug
, librsvg
, libsndfile
, libvdpau
, libvisual
, libwebp
, musepack
, openal
, opencv
, openexr
, opengl-dummy
, openh264
, openjpeg
#, openssl
, opus
, orc
, qt5
, rtmpdump
, schroedinger
, soundtouch
, spandsp
#, vo-aacenc
#, vo-armwbenc
, wayland
, x265
, xorg

, channel
}:

let
  inherit (lib)
    concatStringsSep
    optionals;

  gl_platforms = [ ]
    ++ optionals opengl-dummy.glx [
      "glx"
    ] ++ optionals opengl-dummy.egl [
      "egl"
    ];

  sources = {
    "1.12" = {
      version = "1.12.3";
      sha256 = "36d059761852bed0f1a7fcd3ef64a8aeecab95d2bca53cd6aa0f08054b1cbfec";
    };
  };
  source = sources."${channel}";
in
stdenv.mkDerivation rec {
  name = "gst-plugins-bad-${source.version}";

  src = fetchurl rec {
    urls = map (n: "${n}/${name}.tar.xz") [
      "https://gstreamer.freedesktop.org/src/gst-plugins-bad"
      "mirror://gnome/sources/gst-plugins-bad/${channel}"
    ];
    hashOutput = false;
    inherit (source) sha256;
  };

  nativeBuildInputs = [
    meson
    ninja
    python3
  ];

  buildInputs = [
    bzip2
    chromaprint
    curl
    faac
    faad2
    flite
    game-music-emu
    glib
    gobject-introspection
    gsm
    gst-plugins-base
    gstreamer
    gtk_3
    ladspa-sdk
    libass
    libbs2b
    libmms
    libmodplug
    opus
    librsvg
    libvdpau
    libvisual
    libwebp
    musepack
    openal
    opencv
    openexr
    opengl-dummy
    openh264
    openjpeg
    #openssl
    orc
    qt5
    rtmpdump
    schroedinger
    soundtouch
    spandsp
    #vo-aacenc
    #vo-armwbenc
    wayland
    x265
    xorg.libX11
  ];

  postPatch = ''
    patchShebangs gst-libs/gst/interfaces/build_mkenum.py
    patchShebangs gst-libs/gst/mpegts/mpegts_enum.py
  '' + /* tests are slower than upstream expects */ ''
    sed -e 's:/\* tcase_set_timeout.*:tcase_set_timeout (tc_chain, 5 * 60);:' \
      -i tests/check/elements/audiomixer.c
  '';

  mesonFlags = [
    "-Duse_orc=yes"
    #"-Dwith_gl_api=${if opengl-dummy.glesv2 then "gles2" else "opengl"}"
    "-Dwith_gl_api=opengl"
    "-Dwith_gl_platform=${concatStringsSep "," gl_platforms}"
    "-Ddisable_introspection=false"
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
    description = "Less plugins for GStreamer";
    homepage = http://gstreamer.freedesktop.org;
    license = licenses.lgpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

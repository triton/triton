{ stdenv
, fetchurl
, lib
, python3
, yasm

, bzip2
, ffmpeg
, glib
, gst-plugins-base
, gstreamer
, orc
, xz
, zlib

, channel
}:

let
  inherit (lib)
    boolEn
    boolWt;

  source = (import ./sources.nix { })."${channel}";
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
    python3
    #yasm  # internal libav dependency
  ];

  buildInputs = [
    #bzip2  # internal libav dependency
    ffmpeg
    glib
    gst-plugins-base
    gstreamer
    orc
    #xz  # internal libav dependency
    zlib
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--${boolEn (orc != null)}-orc"
    "--disable-fatal-warnings"
    "--disable-extra-checks"
    "--disable-valgrind"
    "--disable-gcov"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    "--enable-gobject-cast-checks"
    "--disable-glib-asserts"
    "--enable-Bsymbolic"
    "--disable-static-plugins"
    "--enable-gpl"
    "--${boolWt (ffmpeg != null)}-system-libav"
  ];

  NIX_CFLAGS_COMPILE = [
    # Gstreamer lags behind FFmpeg and may use functions marked as deprecated.
    "-Wno-deprecated-declarations"
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

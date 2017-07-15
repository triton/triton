{ stdenv
, fetchurl
, gettext
, lib
, python3

, alsa-lib
, cdparanoia
, glib
, gobject-introspection
, gstreamer
, iso-codes
, libogg
, libtheora
, libvisual
, libvorbis
, opus
, orc
, pango
, xorg
, zlib

, channel
}:

let
  inherit (lib)
    boolEn;

  sources = {
    "1.12" = {
      version = "1.12.2";
      sha256 = "5067dce3afe197a9536fea0107c77213fab536dff4a213b07fc60378d5510675";
    };
  };

  source = sources."${channel}";
in
stdenv.mkDerivation rec {
  name = "gst-plugins-base-${source.version}";

  src = fetchurl rec {
    urls = map (n: "${n}/${name}.tar.xz") [
      "https://gstreamer.freedesktop.org/src/gst-plugins-base"
      "mirror://gnome/sources/gst-plugins-base/${channel}"
    ];
    hashOutput = false;
    inherit (source) sha256;
  };

  nativeBuildInputs = [
    gettext
    python3
  ];

  buildInputs = [
    alsa-lib
    cdparanoia
    glib
    gobject-introspection
    gstreamer
    iso-codes
    libogg
    libtheora
    libvisual
    libvorbis
    opus
    orc
    pango
    xorg.libX11
    xorg.libXext
    xorg.libXv
    xorg.videoproto
    xorg.xextproto
    xorg.xproto
    zlib
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--enable-nls"
    "--enable-rpath"
    "--disable-fatal-warnings"
    "--disable-extra-checks"
    "--disable-debug"
    "--disable-profiling"
    "--disable-valgrind"
    "--disable-gcov"
    "--disable-examples"
    "--enable-external"
    "--enable-experimental"
    "--enable-largefile"
    "--${boolEn (gobject-introspection != null)}-introspection"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    "--enable-gobject-cast-checks"
    "--disable-glib-asserts"
    "--${boolEn (orc != null)}-orc"
    "--enable-Bsymbolic"
    "--disable-static-plugins"
    "--enable-adder"
    "--enable-app"
    "--enable-audioconvert"
    "--enable-audiorate"
    "--enable-audiotestsrc"
    "--enable-encoding"
    "--enable-videoconvert"
    "--enable-gio"
    "--enable-playback"
    "--enable-audioresample"
    "--enable-rawparse"
    "--enable-subparse"
    "--enable-tcp"
    "--enable-typefind"
    "--enable-videotestsrc"
    "--enable-videorate"
    "--enable-videoscale"
    "--enable-volume"
    "--${boolEn (iso-codes != null)}-iso-codes"
    "--${boolEn (zlib != null)}-zlib"
    "--${boolEn (xorg.libX11 != null)}-x"
    "--${boolEn (xorg.libXv != null)}-xvideo"
    "--${boolEn (xorg.libXext != null)}-xshm"
    "--${boolEn (alsa-lib != null)}-alsa"
    "--${boolEn (cdparanoia != null)}-cdparanoia"
    "--disable-ivorbis"
    "--${boolEn (libvisual != null)}-libvisual"
    "--${boolEn (libogg != null)}-ogg"
    "--${boolEn (opus != null)}-opus"
    "--${boolEn (pango != null)}-pango"
    "--${boolEn (libtheora != null)}-theora"
    "--${boolEn (libvorbis != null)}-vorbis"
    "--with-audioresample-format=float"
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
    license = licenses.lgpl2Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

{ stdenv
, fetchurl
, gettext
, lib
, python3

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

  source = (import ./sources.nix { })."${channel}";
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
    python3
  ];

  buildInputs = [
    a52dec
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
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    "--enable-gobject-cast-checks"
    "--disable-glib-asserts"
    "--${boolEn (orc != null)}-orc"
    "--enable-Bsymbolic"
    # Internal plugins
    "--disable-static-plugins"
    "--enable-asfdemux"
    "--enable-dvdlpcmdec"
    "--enable-dvdsub"
    "--enable-xingmux"
    "--enable-realmedia"
    # External plugins
    "--${boolEn (a52dec != null)}-a52dec"
    "--${boolEn (amrnb != null)}-amrnb"
    "--${boolEn (amrnb != null)}-amrwb"
    "--${boolEn (libcdio != null)}-cdio"
    "--${boolEn (libdvdread != null)}-dvdread"
    "--${boolEn (lame != null)}-lame"
    "--${boolEn (libmpeg2 != null)}-mpeg2dec"
    "--${boolEn (mpg123 != null)}-mpg123"
    #"--${boolEn (sidplay != null)}-sidplay"
    /**/"--disable-sidplay"
    #"--${boolEn (twolame != null)}-twolame"
    /**/"--disable-twolame"
    "--${boolEn (x264 != null)}-x264"
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

{ stdenv
, fetchurl
, gettext
, python

, a52dec
, amrnb
, amrwb
, glib
, gst-plugins-base
, gstreamer
, lame
, libcdio
, libdvdread
, libmad
, mpeg2dec
, orc
, x264
}:

with {
  inherit (stdenv.lib)
    enFlag;
};

stdenv.mkDerivation rec {
  name = "gst-plugins-ugly-1.6.2";

  src = fetchurl {
    url = "http://gstreamer.freedesktop.org/src/gst-plugins-ugly/${name}.tar.xz";
    sha256 = "0icqksgkbi1xsf373slxrvlhrsf6lfc3kkpd1nyglrw63hrbdwg7";
  };

  configureFlags = [
    "--disable-maintainer-mode"
    "--enable-nls"
    "--enable-rpath"
    "--disable-fatal-warnings"
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
    "--enable-glib-asserts"
    (enFlag "orc" (orc != null) null)
    # Internal plugins
    "--enable-static-plugins"
    "--enable-asfdemux"
    "--enable-dvdlpcmdec"
    "--enable-dvdsub"
    "--enable-xingmux"
    "--enable-realmedia"
    # External plugins
    (enFlag "a52dec" (a52dec != null) null)
    (enFlag "amrnb" (amrnb != null) null)
    (enFlag "amrwb" (amrnb != null) null)
    (enFlag "cdio" (libcdio != null) null)
    (enFlag "dvdread" (libdvdread != null) null)
    (enFlag "lame" (lame != null) null)
    (enFlag "mad" (libmad != null) null)
    (enFlag "mpeg2dec" (mpeg2dec != null) null)
    #(enFlag "sidplay" (sidplay != null) null)
    #(enFlag "twolame" (twolame != null) null)
    (enFlag "x264" (x264 != null) null)
  ];

  nativeBuildInputs = [
    gettext
    python
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
    libmad
    mpeg2dec
    orc
    x264
  ];

  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    description = "Basepack of plugins for gstreamer";
    homepage = http://gstreamer.freedesktop.org;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];
  };
}

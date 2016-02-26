{ stdenv
, fetchurl
, gettext
, python

, alsa-lib
, cdparanoia
, glib
, gobject-introspection
, gstreamer
, isocodes
, libogg
, libtheora
, libvisual
, libvorbis
, orc
, pango
, tremor
, xorg
, zlib
}:

with {
  inherit (stdenv.lib)
    enFlag;
};

stdenv.mkDerivation rec {
  name = "gst-plugins-base-1.6.3";

  src = fetchurl {
    url = "http://gstreamer.freedesktop.org/src/gst-plugins-base/${name}.tar.xz";
    sha256 = "0xbskifk95rw7jd85sqjrmqh2kys1bpi0inrxyapx1x4vf7ly5dn";
  };

  nativeBuildInputs = [
    gettext
    python
  ];

  buildInputs = [
    alsa-lib
    cdparanoia
    glib
    gobject-introspection
    gstreamer
    isocodes
    libogg
    libtheora
    libvisual
    libvorbis
    orc
    pango
    tremor
    xorg.libX11
    xorg.libXext
    xorg.libXv
    zlib
  ];

  configureFlags = [
    "--enable-option-checking"
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
    "--enable-largefile"
    (enFlag "introspection" (gobject-introspection != null) null)
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    "--enable-gobject-cast-checks"
    "--enable-glib-asserts"
    (enFlag "orc" (orc != null) null)
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
    "--enable-subparse"
    "--enable-tcp"
    "--enable-typefind"
    "--enable-videotestsrc"
    "--enable-videorate"
    "--enable-videoscale"
    "--enable-volume"
    (enFlag "iso-codes" (isocodes != null) null)
    (enFlag "zlib" (zlib != null) null)
    (enFlag "x" (xorg.libX11 != null) null)
    (enFlag "xvideo" (xorg.libXv != null) null)
    (enFlag "xshm" (xorg.libXext != null) null)
    (enFlag "alsa" (alsaLib != null) null)
    (enFlag "cdparanoia" (cdparanoia != null) null)
    (enFlag "ivorbis" (tremor != null) null)
    (enFlag "libvisual" (libvisual != null) null)
    (enFlag "ogg" (libogg != null) null)
    (enFlag "pango" (pango != null) null)
    (enFlag "theora" (libtheora != null) null)
    (enFlag "vorbis" (libvorbis != null) null)
    (enFlag "gio_unix_2_0" (glib != null) null)
    "--disable-freetypetest"
    "--with-audioresample-format=float"
  ];

  meta = with stdenv.lib; {
    description = "Basepack of plugins for gstreamer";
    homepage = http://gstreamer.freedesktop.org;
    license = licenses.lgpl2Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}

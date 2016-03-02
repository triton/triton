{ stdenv
, fetchTritonPatch
, fetchurl

, alsa-lib
, cdparanoia
, freetype
, glib
, gobject-introspection
, gstreamer_0
, isocodes
, libgudev
, libogg
, libtheora
, libv4l
, libvisual
, libvorbis
, libxml2
, orc
, pango
#, tremor
, xorg
, zlib
}:

with {
  inherit (stdenv.lib)
    enFlag
    wtFlag;
};

stdenv.mkDerivation rec {
  name = "gst-plugins-base-0.10.36";

  src = fetchurl {
    url = "http://gstreamer.freedesktop.org/src/gst-plugins-base/${name}.tar.xz";
    sha256 = "0jp6hjlra98cnkal4n6bdmr577q8mcyp3c08s3a02c4hjhw5rr0z";
  };

  patches = [
    (fetchTritonPatch {
      rev = "d3fc5e59bd2b4b465c2652aae5e7428b24eb5669";
      file = "gst-plugins-base/gst-plugins-base-0.10-gcc-4.9.patch";
      sha256 = "823eca6943a793a66154276018a1b682c831dda8939c7eaf29cad953c795b74f";
    })
    (fetchTritonPatch {
      rev = "d3fc5e59bd2b4b465c2652aae5e7428b24eb5669";
      file = "gst-plugins-base/gst-plugins-base-0.10-resync-ringbuffer.patch";
      sha256 = "10624838ca31df3180bbaaf8bdfef6bd52ccaad62735a16f3332a70380e5c94a";
    })
  ];

  postPatch =
    /* Fix hardcoded path */ ''
      sed -i configure \
        -e 's@/bin/echo@echo@g'
    '' +
    /* The AC_PATH_XTRA macro unnecessarily pulls in libSM and libICE even
       though they are not actually used. This needs to be fixed upstream by
       replacing AC_PATH_XTRA with PKG_CONFIG calls. */ ''
      sed -i configure \
        -e 's:X_PRE_LIBS -lSM -lICE:X_PRE_LIBS:'
    '';

  configureFlags = [
    "--enable-option-checking"
    "--disable-maintainer-mode"
    "--enable-nls"
    "--enable-rpath"
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
    "--enable-gobject-cast-checks"
    "--enable-glib-asserts"
    (enFlag "orc" (orc != null) null)
    "--enable-Bsymbolic"
    "--enable-adder"
    "--enable-app"
    "--enable-audioconvert"
    "--enable-audiorate"
    "--enable-audiotestsrc"
    "--enable-encoding"
    "--enable-ffmpegcolorspace"
    "--enable-gdp"
    "--enable-playback"
    # Speex ????
    "--enable-audioresample"
    (enFlag "subparse" (libxml2 != null) null)
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
    (enFlag "gst_v4l" (libv4l != null) null)
    (enFlag "alsa" (alsa-lib != null) null)
    (enFlag "cdparanoia" (cdparanoia != null) null)
    "--disable-gnome_vfs"
    # FIXME: compilation fails with ivorbis(tremor)
    "--disable-ivorbis"
    "--enable-gio"
    (enFlag "libvisual" (libvisual != null) null)
    (enFlag "ogg" (libogg != null) null)
    "--disable-oggtest"
    (enFlag "pango" (pango != null) null)
    (enFlag "theora" (libtheora != null) null)
    (enFlag "vorbis" (libvorbis != null) null)
    "--disable-vorbistest"
    "--disable-freetypetest"
    "--with-audioresample-format=float"
    "--with-x"
    (wtFlag "gudev" (libgudev != null) null)
  ];

  buildInputs = [
    alsa-lib
    cdparanoia
    freetype
    glib
    gobject-introspection
    gstreamer_0
    isocodes
    libgudev
    libogg
    libtheora
    libv4l
    libvisual
    libvorbis
    libxml2
    orc
    pango
    #tremor
    xorg.libX11
    xorg.libXext
    xorg.libXv
    zlib
  ];

  meta = with stdenv.lib; {
    description = "Basepack of plugins for gstreamer";
    homepage = http://gstreamer.freedesktop.org;
    license = licenses.lgpl2plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}

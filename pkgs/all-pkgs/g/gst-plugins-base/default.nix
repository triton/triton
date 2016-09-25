{ stdenv
, fetchurl
, gettext
, pythonPackages

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
, orc
, pango
, xorg
, zlib
}:

let
  inherit (stdenv.lib)
    enFlag;
in
stdenv.mkDerivation rec {
  name = "gst-plugins-base-1.8.3";

  src = fetchurl rec {
    url = "https://gstreamer.freedesktop.org/src/gst-plugins-base/${name}.tar.xz";
    sha256Url = url + ".sha256sum";
    sha256 = "114871d4d63606b4af424a8433cd923e4ff66896b244bb7ac97b9da47f71e79e";
  };

  nativeBuildInputs = [
    gettext
    pythonPackages.python
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
    (enFlag "introspection" (gobject-introspection != null) null)
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    "--enable-gobject-cast-checks"
    "--disable-glib-asserts"
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
    "--disable-ivorbis"
    "--enable-audioresample"
    "--enable-subparse"
    "--enable-tcp"
    "--enable-typefind"
    "--enable-videotestsrc"
    "--enable-videorate"
    "--enable-videoscale"
    "--enable-volume"
    (enFlag "iso-codes" (iso-codes != null) null)
    (enFlag "zlib" (zlib != null) null)
    (enFlag "x" (xorg.libX11 != null) null)
    (enFlag "xvideo" (xorg.libXv != null) null)
    (enFlag "xshm" (xorg.libXext != null) null)
    (enFlag "alsa" (alsa-lib != null) null)
    (enFlag "cdparanoia" (cdparanoia != null) null)
    "--disable-ivorbis"
    (enFlag "libvisual" (libvisual != null) null)
    (enFlag "ogg" (libogg != null) null)
    (enFlag "pango" (pango != null) null)
    (enFlag "theora" (libtheora != null) null)
    (enFlag "vorbis" (libvorbis != null) null)
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
      x86_64-linux;
  };
}

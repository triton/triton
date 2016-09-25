{ stdenv
, fetchurl
, gettext
, pythonPackages

, a52dec
#, amrnb
#, amrwb
, glib
, gst-plugins-base
, gstreamer
, lame
, libcdio
, libdvdread
, libmad
, libmpeg2
, mpg123
, orc
, x264
}:

let
  inherit (stdenv.lib)
    enFlag;
in
stdenv.mkDerivation rec {
  name = "gst-plugins-ugly-1.8.3";

  src = fetchurl rec {
    url = "https://gstreamer.freedesktop.org/src/gst-plugins-ugly/"
      + "${name}.tar.xz";
    sha256Url = url + ".sha256sum";
    sha256 = "6fa2599fdd072d31fbaf50c34af406e2be944a010b1f4eab67a5fe32a0310693";
  };

  nativeBuildInputs = [
    gettext
    pythonPackages.python
  ];

  buildInputs = [
    a52dec
    #amrnb
    #amrwb
    glib
    gst-plugins-base
    gstreamer
    lame
    libcdio
    libdvdread
    libmad
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
    (enFlag "orc" (orc != null) null)
    "--enable-Bsymbolic"
    # Internal plugins
    "--disable-static-plugins"
    "--enable-asfdemux"
    "--enable-dvdlpcmdec"
    "--enable-dvdsub"
    "--enable-xingmux"
    "--enable-realmedia"
    # External plugins
    (enFlag "a52dec" (a52dec != null) null)
    #(enFlag "amrnb" (amrnb != null) null)
    #(enFlag "amrwb" (amrnb != null) null)
    (enFlag "cdio" (libcdio != null) null)
    (enFlag "dvdread" (libdvdread != null) null)
    (enFlag "lame" (lame != null) null)
    (enFlag "mad" (libmad != null) null)
    (enFlag "mpeg2dec" (libmpeg2 != null) null)
    (enFlag "mpg123" (mpg123 != null) null)
    #(enFlag "sidplay" (sidplay != null) null)
    #(enFlag "twolame" (twolame != null) null)
    (enFlag "x264" (x264 != null) null)
  ];

  meta = with stdenv.lib; {
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

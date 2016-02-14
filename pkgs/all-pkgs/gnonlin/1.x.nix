{ stdenv
, fetchurl
, python

, glib
, gst-plugins-base
, gstreamer
}:

stdenv.mkDerivation rec {
  name = "gnonlin-1.4.0";

  src = fetchurl {
    url = "http://gstreamer.freedesktop.org/src/gnonlin/${name}.tar.xz";
    sha256 = "0zv60rq2h736a6fivd3a3wp59dj1jar7b2vwzykahvl168b7wrid";
  };

  configureFlags = [
    "--enable-option-checking"
    "--disable-maintainer-mode"
    "--disable-debug"
    "--disable-valgrind"
    "--disable-gcov"
    "--disable-docbook"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    "--enable-gobject-cast-checks"
    "--enable-glib-asserts"
    "--disable-static-plugins"
  ];

  nativeBuildInputs = [
    python
  ];

  buildInputs = [
    glib
    gst-plugins-base
    gstreamer
  ];

  meta = with stdenv.lib; {
    description = "GStreamer elements for non-linear multimedia editors";
    homepage = http://gstreamer.freedesktop.org;
    license = licenses.lgpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}

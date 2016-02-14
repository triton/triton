{ stdenv
, fetchurl
, python

, glib
, gst-plugins-base_0
, gstreamer_0
}:

stdenv.mkDerivation rec {
  name = "gnonlin-0.10.17";

  src = fetchurl {
    url = "http://gstreamer.freedesktop.org/src/gnonlin/${name}.tar.bz2";
    sha256 = "0dc9kvr6i7sh91cyhzlbx2bchwg84rfa4679ccppzjf0y65dv8p4";
  };

  configureFlags = [
    "--enable-option-checking"
    "--disable-maintainer-mode"
    "--disable-debug"
    "--disable-valgrind"
    "--disable-gcov"
    "--disable-docbook"
    "--disable-gtk-doc"
    "--enable-gobject-cast-checks"
    "--enable-glib-asserts"
  ];

  nativeBuildInputs = [
    python
  ];

  buildInputs = [
    glib
    gst-plugins-base_0
    gstreamer_0
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

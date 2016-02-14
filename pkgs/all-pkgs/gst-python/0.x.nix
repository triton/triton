{ stdenv
, fetchTritonPatch
, fetchurl

, gst-plugins-base_0
, gstreamer_0
, libxml2
, python2
, python2Packages
}:

stdenv.mkDerivation rec {
  name = "gst-python-0.10.22";

  src = fetchurl {
    url = "http://gstreamer.freedesktop.org/src/gst-python/${name}.tar.bz2";
    sha256 = "0y1i4n5m1diljqr9dsq12anwazrhbs70jziich47gkdwllcza9lg";
  };

  patches = [
    # https://bugzilla.gnome.org/show_bug.cgi?id=692479
    (fetchTritonPatch {
      rev = "d3fc5e59bd2b4b465c2652aae5e7428b24eb5669";
      file = "gst-python/gst-python-0.10-disable-broken-test.patch";
      sha256 = "b8d3147dd22899f7d75e0933470514a02474a3f2a47fb99c835fce7ac0aab5d4";
    })
  ];

  postPatch =
  /* Fix for newer autotools */ ''
    sed -i configure.ac \
      -e 's/AM_CONFIG_HEADER/AC_CONFIG_HEADERS/g'
  '';

  configureFlags = [
    "--disable-maintainer-mode"
    "--disable-gcov"
    "--disable-valgrind"
  ];

  buildInputs = [
    gst-plugins-base_0
    gstreamer_0
    libxml2
    python2
    python2Packages.pygobject
    python2Packages.pygtk
  ];

  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    description = "A Python Interface to GStreamer";
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

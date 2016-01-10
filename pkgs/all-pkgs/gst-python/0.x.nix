{ stdenv
, fetchurl

, gst-plugins-base_0
, gstreamer_0
, libxml2
, python
, pythonPackages
}:

stdenv.mkDerivation rec {
  name = "gst-python-0.10.22";

  src = fetchurl {
    url = "http://gstreamer.freedesktop.org/src/gst-python/${name}.tar.bz2";
    sha256 = "0y1i4n5m1diljqr9dsq12anwazrhbs70jziich47gkdwllcza9lg";
  };

  patches = [
    # https://bugzilla.gnome.org/show_bug.cgi?id=692479
    ./gst-python-0.10-disable-broken-test.patch
  ];

  postPatch = ''
    # Fix for newer autotools
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
    python
    pythonPackages.pygobject
    pythonPackages.pygtk
  ];

  meta = with stdenv.lib; {
    description = "A Python Interface to GStreamer";
    homepage = http://gstreamer.freedesktop.org;
    license = licenses.lgpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];
  };
}

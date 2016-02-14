{ stdenv
, fetchTritonPatch
, fetchurl

, gstreamer
, gst-plugins-base
, ncurses
, python3
, python3Packages
}:

stdenv.mkDerivation rec {
  name = "gst-python-1.6.2";

  src = fetchurl {
    url = "http://gstreamer.freedesktop.org/src/gst-python/${name}.tar.xz";
    sha256 = "09ci5zvr7lms7mvgbjgsjwaxcl4nq45n1g9pdwnqmx3rf0qkwxjf";
  };

  patches = [
    (fetchTritonPatch {
      rev = "d3fc5e59bd2b4b465c2652aae5e7428b24eb5669";
      file = "gst-python/gst-python-1.0-different-path-with-pygobject.patch";
      sha256 = "7c83295005351c1bffd9c5d1816647753c434c8bdaf575779c25afd31eaa4adb";
    })
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--disable-valgrind"
    # Fix override directory with Python3.5
    "--with-pygi-overrides-dir=\${out}/lib/python3.5/site-packages/gi/overrides"
  ];

  buildInputs = [
    gst-plugins-base
    gstreamer
    ncurses
    python3
    python3Packages.pygobject3
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

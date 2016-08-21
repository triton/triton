{ stdenv
, fetchTritonPatch
, fetchurl

, gstreamer
, gst-plugins-base
, ncurses
, pythonPackages
}:

stdenv.mkDerivation rec {
  name = "gst-python-1.8.3";

  src = fetchurl rec {
    url = "https://gstreamer.freedesktop.org/src/gst-python/${name}.tar.xz";
    sha256Url = "${url}.sha256sum";
    sha256 = "149e7b9c2c361832bc765d39bce004d1ffe1b330c09c42dc902ca48867e804ce";
  };

  buildInputs = [
    gst-plugins-base
    gstreamer
    ncurses
    pythonPackages.python
    pythonPackages.pygobject3
    pythonPackages.wrapPython
  ];

  patches = [
    (fetchTritonPatch {
      rev = "d3fc5e59bd2b4b465c2652aae5e7428b24eb5669";
      file = "gst-python/gst-python-1.0-different-path-with-pygobject.patch";
      sha256 = "7c83295005351c1bffd9c5d1816647753c434c8bdaf575779c25afd31eaa4adb";
    })
  ];

  preConfigure = ''
    configureFlagsArray+=(
      # Fix overrides site directory
      "--with-pygi-overrides-dir=$out/lib/${pythonPackages.python.libPrefix}/site-packages/gi/overrides"
    )
  '';

  configureFlags = [
    "--disable-maintainer-mode"
    "--disable-valgrind"
  ];

  meta = with stdenv.lib; {
    description = "A Python Interface to GStreamer";
    homepage = https://gstreamer.freedesktop.org;
    license = licenses.lgpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

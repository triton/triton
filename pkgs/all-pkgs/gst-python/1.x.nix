{ stdenv
, fetchTritonPatch
, fetchurl

, gstreamer
, gst-plugins-base
, ncurses
, python3Packages
}:

stdenv.mkDerivation rec {
  name = "gst-python-1.8.0";

  src = fetchurl rec {
    url = "https://gstreamer.freedesktop.org/src/gst-python/${name}.tar.xz";
    sha256Url = "${url}.sha256sum";
    sha256 = "ce45ff17c59f86a3a525685e37b95e6a78a019e709f66a5c4b462a7f7a22f6ea";
  };

  buildInputs = [
    gst-plugins-base
    gstreamer
    ncurses
    python3Packages.python
    python3Packages.pygobject3
  ];

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

  meta = with stdenv.lib; {
    description = "A Python Interface to GStreamer";
    homepage = http://gstreamer.freedesktop.org;
    license = licenses.lgpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

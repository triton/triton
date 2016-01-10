{ stdenv
, fetchurl
, python
, yasm # internal libav

, bzip2
, gst-plugins-base
, gstreamer
, orc
, xz
, zlib # internal libav
}:

stdenv.mkDerivation rec {
  name = "gst-libav-1.6.2";

  src = fetchurl {
    url = "http://gstreamer.freedesktop.org/src/gst-libav/${name}.tar.xz";
    sha256 = "0s9lvd0cgask459nwijpsl9v2lfzhw54806ky14ns03i070ar5r5";
  };

  configureFlags = [
    "--disable-maintainer-mode"
    "--enable-orc"
    "--disable-fatal-warnings"
    "--disable-valgrind"
    "--disable-gcov"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    "--disable-static-plugins"
    "--enable-gpl"
    # Upstream dropped support for system libav
    # http://bugzilla.gnome.org/show_bug.cgi?id=758183
    "--without-system-libav"
  ];

  nativeBuildInputs = [
    python
    yasm
  ];

  buildInputs = [
    bzip2
    gst-plugins-base
    gstreamer
    orc
    xz
    zlib
  ];

  meta = with stdenv.lib; {
    description = "FFmpeg based gstreamer plugin";
    homepage = http://gstreamer.freedesktop.org;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];
  };
}

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

with {
  inherit (stdenv.lib)
    enFlag;
};

stdenv.mkDerivation rec {
  name = "gst-libav-1.6.3";

  src = fetchurl {
    url = "http://gstreamer.freedesktop.org/src/gst-libav/${name}.tar.xz";
    sha256 = "1aylbg1xnm68c3wc49mzx813qhsjfg23hqnjqqwdwdq31839qyw5";
  };

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

  configureFlags = [
    "--disable-maintainer-mode"
    (enFlag "orc" (orc != null) null)
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

  meta = with stdenv.lib; {
    description = "FFmpeg based gstreamer plugin";
    homepage = http://gstreamer.freedesktop.org;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}

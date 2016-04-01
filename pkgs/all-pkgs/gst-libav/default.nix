{ stdenv
, fetchurl
, python
, yasm # internal libav

, bzip2
, glib
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
  name = "gst-libav-1.8.0";

  src = fetchurl rec {
    url = "https://gstreamer.freedesktop.org/src/gst-libav/${name}.tar.xz";
    sha256Url = "${url}.sha256sum";
    sha256 = "5a1ce28876aee93cb4f3d090f0e807915a5d9bc1325e3480dd302b85aeb4291c";
  };

  nativeBuildInputs = [
    python
    yasm
  ];

  buildInputs = [
    bzip2
    glib
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
    "--disable-extra-checks"
    "--disable-valgrind"
    "--disable-gcov"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    "--enable-gobject-cast-checks"
    "--enable-glib-asserts"
    "--enable-Bsymbolic"
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
      x86_64-linux;
  };
}

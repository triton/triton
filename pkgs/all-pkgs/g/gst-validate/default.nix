{ stdenv
, fetchurl
, gettext

, glib
, gobject-introspection
, gst-plugins-base
, gstreamer
, pythonPackages
}:

let
  inherit (stdenv.lib)
    enFlag;
in
stdenv.mkDerivation rec {
  name = "gst-validate-1.8.3";

  src = fetchurl rec {
    url = "https://gstreamer.freedesktop.org/src/gst-validate/${name}.tar.xz";
    sha256Url = url + ".sha256sum";
    sha256 = "4525a4fb5b85b8a49674e00d652bee9ac62c56241c148abbff23efa50a224e34";
  };

  nativeBuildInputs = [
    gettext
  ];

  buildInputs = [
    glib
    gobject-introspection
    gst-plugins-base
    gstreamer
    pythonPackages.python
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--enable-nls"
    "--enable-rpath"
    "--disable-debug"
    "--disable-valgrind"
    "--disable-gcov"
    (enFlag "introspection" (gobject-introspection != null) null)
    "--disable-docbook"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    "--enable-glib-cast-checks"
    "--enable-glib-asserts"
  ];

  meta = with stdenv.lib; {
    description = "Integration testing infrastructure for the GStreamer framework";
    homepage = "https://gstreamer.freedesktop.org";
    license = licenses.lgpl2Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

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
  name = "gst-validate-1.8.2";

  src = fetchurl rec {
    url = "https://gstreamer.freedesktop.org/src/gst-validate/${name}.tar.xz";
    sha256Url = "${url}.sha256sum";
    sha256 = "33c5b585c5ca1659fe6c09fdf02e45d8132c0d386b405bf527b14ab481a0bafe";
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
    homepage = "http://gstreamer.freedesktop.org";
    license = licenses.lgpl2Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

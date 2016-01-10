{ stdenv
, fetchurl
, gettext

, glib
, gobject-introspection
, gst-plugins-base
, gstreamer
, python
}:

with {
  inherit (stdenv.lib)
    enFlag;
};

stdenv.mkDerivation rec {
  name = "gst-validate-1.6.0";

  src = fetchurl {
    url = "${meta.homepage}/src/gst-validate/${name}.tar.xz";
    sha256 = "1vmg5mh068zrvhgrjsbnb7y4k632akyhm8ql0g196cinnp3zibiv";
  };

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

  nativeBuildInputs = [
    gettext
  ];

  buildInputs = [
    glib
    gobject-introspection
    gst-plugins-base
    gstreamer
    python
  ];

  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    description = "Integration testing infrastructure for the GStreamer framework";
    homepage = "http://gstreamer.freedesktop.org";
    license = licenses.lgpl2Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];
  };
}

{ stdenv
, fetchurl
, flex
, perl
, python

, glib
, gnonlin
, gobject-introspection
, gst-plugins-base
, gstreamer
, libxml2
}:

with {
  inherit (stdenv.lib)
    enFlag;
};

stdenv.mkDerivation rec {
  name = "gstreamer-editing-services-1.6.2";

  src = fetchurl {
    url = "http://gstreamer.freedesktop.org/src/gstreamer-editing-services/" +
          "${name}.tar.xz";
    sha256 = "1i20bmj8qd8ybl728iv2v1w69gbspnksqw6jz4i1zxvsmi5ifani";
  };

  configureFlags = [
    "--disable-maintainer-mode"
    "--disable-debug"
    "--disable-profiling"
    "--disable-valgrind"
    "--disable-gcov"
    "--disable-examples"
    (enFlag "introspection" (gobject-introspection != null) null)
    "--disable-docbook"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    "--enable-gobject-cast-checks"
    "--enable-glib-asserts"
    "--enable-plugins"
    "--disable-benchmarks"
    "--disable-static-plugins"
    "--without-gtk"
  ];

  nativeBuildInputs = [
    flex
    perl
    python
  ];

  buildInputs = [
    glib
    gnonlin
    gobject-introspection
    gst-plugins-base
    gstreamer
    libxml2
  ];

  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    description = "SDK for making video editors and more";
    homepage = http://gstreamer.freedesktop.org;
    license = licenses.lgpl2plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];
  };
}

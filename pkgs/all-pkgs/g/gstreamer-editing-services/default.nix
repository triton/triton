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

let
  inherit (stdenv.lib)
    enFlag;
in

stdenv.mkDerivation rec {
  name = "gstreamer-editing-services-1.8.2";

  src = fetchurl rec {
    url = "https://gstreamer.freedesktop.org/src/gstreamer-editing-services/" +
          "${name}.tar.xz";
    sha256Url = "${url}.sha256sum";
    sha256 = "a1d57ff9461407cca1f6e7a9f31a5bdb73f73f33c488a3e3318b27e10a4332ae";
  };

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

  configureFlags = [
    "--disable-maintainer-mode"
    "--disable-fatal-warnings"
    "--disable-extra-checks"
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
    "--enable-Bsymbolic"
    "--disable-benchmarks"
    "--disable-static-plugins"
    "--without-gtk"
  ];

  meta = with stdenv.lib; {
    description = "SDK for making video editors and more";
    homepage = http://gstreamer.freedesktop.org;
    license = licenses.lgpl2plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

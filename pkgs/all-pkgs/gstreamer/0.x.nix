{ stdenv
, bison
, fetchurl
, flex
, gettext
, perl

, glib
, gobject-introspection
, libxml2
}:

stdenv.mkDerivation rec {
  name = "gstreamer-0.10.36";

  src = fetchurl {
    url = "http://gstreamer.freedesktop.org/src/gstreamer/${name}.tar.xz";
    sha256 = "1nkid1n2l3rrlmq5qrf5yy06grrkwjh3yxl5g0w58w0pih8allci";
  };

  setupHook = ./setup-hook-0.10.sh;

  patches = [
    ./gstreamer-0.10-make-grammar.y-work-with-bison-3.patch
  ];

  configureFlags = [
    "--enable-option-checking"
    "--disable-maintainer-mode"
    "--enable-nls"
    "--enable-rpath"
    "--disable-gst-debug"
    "--enable-loadsave"
    "--enable-parse"
    "--enable-option-parsing"
    "--disable-trace"
    "--disable-alloc-trace"
    "--enable-registry"
    "--enable-net"
    "--enable-plugin"
    "--disable-debug"
    "--disable-profiling"
    "--disable-valgrind"
    "--disable-gcov"
    "--disable-examples"
    "--disable-tests"
    "--disable-failing-tests"
    "--disable-poisoning"
    "--enable-largefile"
    "--enable-introspection"
    "--disable-docbook"
    "--disable-gtk-doc"
    "--enable-gobject-cast-checks"
    "--enable-glib-asserts"
    "--disable-check"
    "--enable-Bsymbolic"
  ];

  nativeBuildInputs = [
    bison
    flex
    gettext
    perl
  ];

  buildInputs = [
    glib
    gobject-introspection
    libxml2
  ];

  preFixup = ''
    # Needed for orc-using gst plugins on hardened/PaX systems
    paxmark m \
      $out/bin/gst-launch* \
      $out/libexec/gstreamer-0.10/gst-plugin-scanner
  '';

  meta = with stdenv.lib; {
    description = "Streaming media framework";
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

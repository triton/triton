{ stdenv
, bison
, fetchurl
, flex
, gettext
, lib
, perl
, python

, glib
, gobject-introspection
, libcap

, channel
}:

let
  inherit (lib)
    boolEn;

  source = (import ./sources.nix { })."${channel}";
in
stdenv.mkDerivation rec {
  name = "gstreamer-${source.version}";

  src = fetchurl rec {
    urls = map (n: "${n}/${name}.tar.xz") [
      "https://gstreamer.freedesktop.org/src/gstreamer"
      "mirror://gnome/sources/gstreamer/${channel}"
    ];
    hashOutput = false;
    inherit (source) sha256;
  };

  nativeBuildInputs = [
    bison
    flex
    gettext
    perl
    python
  ];

  buildInputs = [
    glib
    gobject-introspection
    libcap
  ];

  setupHook = ./setup-hook.sh;

  configureFlags = [
    "--disable-maintainer-mode"
    "--enable-nls"
    "--enable-rpath"
    "--disable-fatal-warnings"
    "--disable-extra-checks"
    "--enable-gst-debug"
    "--disable-gst-tracer-hooks"
    "--enable-parse"
    "--enable-option-parsing"
    "--disable-trace"
    "--disable-alloc-trace"
    "--enable-registry"
    "--enable-plugin"
    "--disable-debug"
    "--disable-profiling"
    "--disable-valgrind"
    "--disable-gcov"
    "--disable-examples"
    "--disable-static-plugins"
    "--disable-tests"
    "--disable-failing-tests"
    "--disable-benchmarks"
    "--enable-tools"
    "--disable-poisoning"
    "--enable-largefile"
    "--${boolEn (gobject-introspection != null)}-introspection"
    "--disable-docbook"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    "--enable-gobject-cast-checks"
    "--disable-glib-asserts"
    "--disable-check"
    "--enable-Bsymbolic"
  ];

  preFixup =
    /* Needed for orc-using gst plugins on hardened/PaX systems */ ''
      paxmark m \
        $out/bin/gst-launch* \
        $out/libexec/gstreamer-1.0/gst-plugin-scanner
    '';

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      sha256Urls = map (n: "${n}.sha256sum") src.urls;
      pgpsigUrls = map (n: "${n}.asc") src.urls;
      # Sebastian Dröge
      pgpKeyFingerprint = "7F4B C7CC 3CA0 6F97 336B  BFEB 0668 CC14 86C2 D7B5";
      failEarly = true;
    };
  };

  meta = with lib; {
    description = "Multimedia framework";
    homepage = http://gstreamer.freedesktop.org;
    license = licenses.lgpl2Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

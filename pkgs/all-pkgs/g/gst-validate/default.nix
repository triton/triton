{ stdenv
, fetchurl
, gettext
, lib
# , meson
# , ninja

, glib
, gobject-introspection
, gst-plugins-base
, gstreamer
, json-glib
, python3

, channel
}:

let
  inherit (lib)
    boolEn;

  sources = {
    "1.14" = {
      version = "1.14.0";
      sha256 = "33df08bf77f2895d64b7e8a957de3b930b4da0a8edabfbefcff2eab027eeffdf";
    };
  };

  source = sources."${channel}";
in
stdenv.mkDerivation rec {
  name = "gst-validate-${source.version}";

  src = fetchurl rec {
    urls = map (n: "${n}/${name}.tar.xz") [
      "https://gstreamer.freedesktop.org/src/gst-validate"
      "mirror://gnome/sources/gst-validate/${channel}"
    ];
    hashOutput = false;
    inherit (source) sha256;
  };

  # nativeBuildInputs = [
  #   meson
  #   ninja
  # ];

  buildInputs = [
    glib
    gobject-introspection
    gst-plugins-base
    gstreamer
    json-glib
    python3
  ];

  # mesonFlags = [
  #   "-Ddisable_gtkdoc=true"
  # ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--enable-nls"
    "--enable-rpath"
    "--disable-debug"
    "--disable-valgrind"
    "--disable-gcov"
    "--${boolEn (gobject-introspection != null)}-introspection"
    "--disable-docbook"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    "--enable-glib-cast-checks"
    "--disable-glib-asserts"
  ];

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      sha256Urls = map (n: "${n}.sha256sum") src.urls;
      pgpsigUrls = map (n: "${n}.asc") src.urls;
      pgpKeyFingerprints = [
        # Sebastian Dröge
        "7F4B C7CC 3CA0 6F97 336B  BFEB 0668 CC14 86C2 D7B5"
        # Tim-Philipp Müller
        "D637 032E 45B8 C658 5B94  5656 5D2E EE6F 6F34 9D7C"
      ];
      failEarly = true;
    };
  };

  meta = with lib; {
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

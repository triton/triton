{ stdenv
, fetchurl
, gettext
, lib

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
    "1.12" = {
      version = "1.12.4";
      sha256 = "f9da9dfe6e5d6f5ba3b38c5752b42d3f927715904942b405c2924d3cb77afba1";
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

  buildInputs = [
    glib
    gobject-introspection
    gst-plugins-base
    gstreamer
    json-glib
    python3
  ];

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
      # Sebastian Dröge
      pgpKeyFingerprint = "7F4B C7CC 3CA0 6F97 336B  BFEB 0668 CC14 86C2 D7B5";
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

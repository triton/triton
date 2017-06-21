{ stdenv
, fetchurl
, flex
, lib
, perl
, python3

, glib
, gnonlin
, gobject-introspection
, gst-plugins-base
, gstreamer
, libxml2

, channel
}:

let
  inherit (lib)
    boolEn;

  source = (import ./sources.nix { })."${channel}";
in
stdenv.mkDerivation rec {
  name = "gstreamer-editing-services-${source.version}";

  src = fetchurl rec {
    urls = map (n: "${n}/${name}.tar.xz") [
      "https://gstreamer.freedesktop.org/src/gstreamer-editing-services"
      "mirror://gnome/sources/gstreamer-editing-services/${channel}"
    ];
    hashOutput = false;
    inherit (source) sha256;
  };

  nativeBuildInputs = [
    flex
    perl
    python3
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
    "--${boolEn (gobject-introspection != null)}-introspection"
    "--disable-docbook"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    "--enable-gobject-cast-checks"
    "--disable-glib-asserts"
    "--enable-plugins"
    "--enable-Bsymbolic"
    "--disable-benchmarks"
    "--disable-static-plugins"
    #"--with-bash-completion-dir"
    "--without-gtk"
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

{ stdenv
, bison
, fetchurl
, flex
, gettext
, lib
, meson
, ninja
, python3

, glib
, gobject-introspection
, libcap

, channel
}:

let
  inherit (lib)
    boolEn;

  sources = {
    "1.12" = {
      version = "1.12.4";
      sha256 = "5a8704aa4c2eeb04da192c4a9942f94f860ac1a585de90d9f914bac26a970674";
    };
  };

  source = sources."${channel}";
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
    meson
    ninja
    python3
  ];

  buildInputs = [
    glib
    gobject-introspection
    libcap
  ];

  setupHook = ./setup-hook.sh;

  postPatch = ''
    patchShebangs libs/gst/controller/controller_mkenum.py
  '';

  mesonFlags = [
    "-Dbuild_tools=false"
    "-Dpoisoning=false"
    "-Ddisable_gtkdoc=true"
    "-Ddisable_examples=true"
    "-Ddisable_gst_debug=true"
    "-Ddisable_registry=false"
    "-Ddisable_tracer_hooks=true"
    "-Dlibrary_format=shared"
    "-Ddisable_introspection=false"
    "-Ddisable_libunwind=false"
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

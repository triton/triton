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
    "1.14" = {
      version = "1.14.0";
      sha256 = "fc361367f0d4b780a868a8833f9f30b9c9f4ac9faea4e6b251db8b4b0398466e";
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
    "-Ddisable_gtkdoc=true"
    "-Ddisable_examples=true"
    "-Ddisable_gst_debug=true"
    "-Ddisable_tracer_hooks=true"
    "-Dlibrary_format=shared"
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

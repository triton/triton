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
      version = "1.12.3";
      sha256 = "d388f492440897f02b01eebb033ca2d41078a3d85c0eddc030cdea5a337a216e";
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

{ stdenv
, fetchTritonPatch
, fetchurl
, isPy2
, lib
, pkgs

, glib
, gst-plugins-base
, gstreamer
, ncurses
, pygobject
, python
, wrapPython

, channel
}:

let
  sources = {
    "1.14" = {
      version = "1.14.2";
      sha256 = "dc40be5ab4f1a433ff3f0af2b3d2d79a363009020c41ec10f9747ba64200cb22";
    };
  };

  source = sources."${channel}";
in
stdenv.mkDerivation rec {
  name = "gst-python-${source.version}";

  src = fetchurl rec {
    urls = map (n: "${n}/${name}.tar.xz") [
      "https://gstreamer.freedesktop.org/src/gst-python"
      "mirror://gnome/sources/gst-python/${channel}"
    ];
    hashOutput = false;
    inherit (source) sha256;
  };

  nativeBuildInputs = [
    pkgs.meson
    pkgs.ninja
  ];

  buildInputs = [
    glib
    gst-plugins-base
    gstreamer
    ncurses
    python
    pygobject
    wrapPython
  ];

  # patches = [
  #   (fetchTritonPatch {
  #     rev = "d3fc5e59bd2b4b465c2652aae5e7428b24eb5669";
  #     file = "gst-python/gst-python-1.0-different-path-with-pygobject.patch";
  #     sha256 = "7c83295005351c1bffd9c5d1816647753c434c8bdaf575779c25afd31eaa4adb";
  #   })
  # ];

  postPatch = ''
    sed -i scripts/pythondetector \
      -e 's,#!.*,#!${python.interpreter},'
  '';

  preConfigure = ''
    mesonFlagsArray+=(
      # Fix overrides site directory
      "-Dpygi-overrides-dir=$out/lib/${python.libPrefix}/site-packages/gi/overrides"
    )
  '';

  # FIXME: Cannot build with meson, because meson only supports Py3
  disabled = isPy2;

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
    description = "A Python Interface to GStreamer";
    homepage = https://gstreamer.freedesktop.org;
    license = licenses.lgpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

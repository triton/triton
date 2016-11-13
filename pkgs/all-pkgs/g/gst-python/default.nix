{ stdenv
, fetchTritonPatch
, fetchurl
, lib

, gst-plugins-base
, gstreamer
, ncurses
, pythonPackages

, channel
}:

let
  source = (import ./sources.nix { })."${channel}";
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

  buildInputs = [
    gst-plugins-base
    gstreamer
    ncurses
    pythonPackages.python
    pythonPackages.pygobject3
    pythonPackages.wrapPython
  ];

  patches = [
    (fetchTritonPatch {
      rev = "d3fc5e59bd2b4b465c2652aae5e7428b24eb5669";
      file = "gst-python/gst-python-1.0-different-path-with-pygobject.patch";
      sha256 = "7c83295005351c1bffd9c5d1816647753c434c8bdaf575779c25afd31eaa4adb";
    })
  ];

  preConfigure = ''
    configureFlagsArray+=(
      # Fix overrides site directory
      "--with-pygi-overrides-dir=$out/lib/${pythonPackages.python.libPrefix}/site-packages/gi/overrides"
    )
  '';

  configureFlags = [
    "--disable-maintainer-mode"
    "--disable-valgrind"
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

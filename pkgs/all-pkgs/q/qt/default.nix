{ stdenv
, bison
, fetchurl
, gperf
, lib
, perl
, python2
, which

, alsa-lib
, bluez
, cups
, dbus
, double-conversion
, expat
, fontconfig
, freetype
, glib
, gstreamer
, gst-plugins-base
, harfbuzz_lib
, hunspell
, icu
, libcap
, libdrm
, libevdev
, libinput
, libjpeg
, libpng
, libproxy
, libx11
, libxcb
, libxcomposite
, libxcursor
, libxdamage
, libxext
, libxfixes
, libxi
, libxkbcommon
, libxrandr
, libxrender
, libxscrnsaver
, libxtst
, mariadb-connector-c
, mtdev
, opengl-dummy
, openssl
, pciutils
, pcre2
, postgresql
, pulseaudio_lib
, sqlite
, systemd_lib
, tslib
, wayland
, xorg
, xorgproto
, zlib

, buildWebEngine ? false
}:

let
  channel = "5.11";
  version = "${channel}.1";

  inherit (lib)
    optionals;
in
stdenv.mkDerivation rec {
  name = "qt-${version}";

  src = fetchurl {
    url = "http://download.qt.io/official_releases/qt/${channel}/${version}"
      + "/single/qt-everywhere-src-${version}.tar.xz";
    hashOutput = false;
    fullOpts = {
      md5Confirm = "c6f0854d7de7bde80cfd8cc85bb7152b";
      sha1Confirm = "0ac866442a960d4038a51ba3096b2cc5d796b5ee";
    };
    sha256 = "39602cb08f9c96867910c375d783eed00fc4a244bffaa93b801225d17950fb2b";
  };

  nativeBuildInputs = [
    perl
    python2
    which
  ] ++ optionals buildWebEngine [
    bison
    gperf
  ];

  buildInputs = [
    alsa-lib
    bluez
    cups
    dbus
    double-conversion
    fontconfig
    freetype
    glib
    gstreamer
    gst-plugins-base
    harfbuzz_lib
    icu
    libdrm
    libevdev
    libinput
    libjpeg
    libpng
    libproxy
    libx11
    libxcb
    libxcomposite
    libxext
    libxfixes
    libxi
    libxkbcommon
    libxrender
    mariadb-connector-c
    mtdev
    opengl-dummy
    openssl
    pcre2
    postgresql
    pulseaudio_lib
    sqlite
    systemd_lib
    tslib
    wayland
    xorg.xcbutilimage
    xorg.xcbutilkeysyms
    xorg.xcbutilrenderutil
    xorg.xcbutilwm
    xorgproto
    zlib
  ] ++ optionals buildWebEngine [
    expat
    hunspell
    libcap
    libxcursor
    libxdamage
    libxrandr
    libxtst
    libxscrnsaver
    pciutils
  ];

  inherit version;
  setupHook = ./setup-hook.sh;
  selfApplySetupHook = true;

  postPatch = ''
    # Fix references to pwd
    find . -name configure -type f | xargs -n 1 -P $NIX_BUILD_CORES sed -i \
      -e "s,/bin/pwd,$(type -tP pwd),g"

    # Fix parallel building qmake
    sed \
      -e "s,\"\$MAKE\" -f,\"\$MAKE\" -j $NIX_BUILD_CORES -f,g" \
      -e "s,; \"\$MAKE\",; \"\$MAKE\" -j $NIX_BUILD_CORES,g" \
      -i qtbase/configure

    # Fix gyp files
    find qtwebengine -name \*.gyp\* -type f | xargs -n 1 -P $NIX_BUILD_CORES sed -i "s,/bin/echo,$(type -tP echo),g"
  '';

  prefixKey = "-prefix ";

  preConfigure = /* Use a more predictable directory for plugins than $out/plugins */ ''
    configureFlagsArray+=('-plugindir' "$out/lib/qt-${version}/plugins")
  '';

  configureFlags = [
    "-release"
    "-opensource"
    "-confirm-license"

    "-sql-mysql"
    "-no-sql-odbc"
    "-no-sql-oci"
    "-sql-psql"
    "-no-sql-tds"
    "-no-sql-db2"
    "-sql-sqlite"
    "-no-sql-sqlite2"
    "-no-sql-ibase"
    "-system-sqlite"

    "-no-qml-debug"

    "-no-avx"
    "-no-avx2"
    "-no-avx512"

    "-system-zlib"
    "-mtdev"
    "-journald"
    "-syslog"
    "-system-libpng"
    "-system-libjpeg"
    "-system-doubleconversion"
    "-system-freetype"
    "-system-harfbuzz"
    "-openssl-linked"
    "-libproxy"
    "-system-pcre"
    "-system-xcb"
    "-system-xkbcommon-x11"
    "-xinput2"
    "-xcb-xlib"
    "-glib"
    "-pulseaudio"
    "-alsa"
    "-no-gtk" # TODO: Figure out how to enable this

    "-nomake" "examples"
    "-no-compile-examples"
    "-verbose"
    "-cups"
    "-no-iconv"
    "-evdev"
    "-tslib"
    "-icu"
    "-fontconfig"
    "-strip"
    "-dbus-linked"
    "-use-gold-linker"
    "-xcb"
    "-eglfs"
    "-kms"
    "-gbm"
    "-no-directfb"
    "-linuxfb"
    "-no-mirclient"
    "-libinput"
    "-gstreamer" "1.0"
    "-system-proxies"

    # Disable unused QT submodules
    "-skip" "3d"
    "-skip" "activeqt"
    "-skip" "androidextras"
    "-skip" "canvas3d"
    "-skip" "charts"
    "-skip" "connectivity"
    "-skip" "datavis3d"
    "-skip" "doc"
    "-skip" "gamepad"
    "-skip" "imageformats"
    "-skip" "macextras"
    "-skip" "purchasing"
    "-skip" "quickcontrols2"
    "-skip" "scxml"
    "-skip" "sensors"
    "-skip" "serialbus"
    "-skip" "serialport"
    "-skip" "virtualkeyboard"
    "-skip" "webview"
    "-skip" "winextras"
  ] ++ optionals (!buildWebEngine) [
    "-skip" "location"
    "-skip" "webchannel"
    "-skip" "webengine"
  ];

  # For some reason libdrm doesn't map drm.h correctly
  NIX_CFLAGS_COMPILE = "-I${libdrm}/include/libdrm";

  # This is really broken and should be fixed uptream
  preFixup = ''
    find $out/lib/pkgconfig -name \*.pc -exec sed -i 's,Qt5UiPlugin,,g' {} \;
  '';

  buildDirCheck = false;  # FIXME

  passthru = {
    inherit version;

    plugindir = "lib/qt-${version}/plugins";

    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      md5Url = "https://download.qt.io/official_releases/qt/"
        + "${channel}/${version}/single/md5sums.txt";
    };
  };

  meta = with lib; {
    description = "Cross-platform toolkit for embedded & desktop";
    homepage = https://www.qt.io;
    license = with licenses; [
      fdl13
      gpl3
      lgpl3
    ];
    maintainers = with maintainers; [
      codyopel
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

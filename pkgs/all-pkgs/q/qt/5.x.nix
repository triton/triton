{ stdenv
, bison
, fetchurl
, gperf
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
, libxkbcommon
, mesa
, mtdev
, mysql
, openssl_1-0-2
, pciutils
, pcre
, postgresql
, pulseaudio_lib
, sqlite
, systemd_lib
, tslib
, wayland
, xorg
, zlib

, buildWebEngine ? false
}:

let
  versionMajor = "5.8";
  versionPatch = "0";
  version = "${versionMajor}.${versionPatch}";

  inherit (stdenv.lib)
    optionals;
in
stdenv.mkDerivation rec {
  name = "qt-${version}";

  src = fetchurl {
    url = "http://download.qt.io/official_releases/qt/${versionMajor}/${version}"
      + "/single/qt-everywhere-opensource-src-${version}.tar.xz";
    hashOutput = false;
    md5Confirm = "66660cd3d9e1a6fed36e88adcb72e9fe";
    sha1Confirm = "1a056ca4f731798e4142a691d0448c2c853228ca";
    sha256 = "0f4c54386d3dbac0606a936a7145cebb7b94b0ca2d29bc001ea49642984824b6";
  };

  nativeBuildInputs = [
    perl
    python2
  ] ++ optionals buildWebEngine [
    bison
    gperf
    which
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
    libxkbcommon
    mesa
    mtdev
    mysql
    openssl_1-0-2
    pcre
    postgresql
    pulseaudio_lib
    sqlite
    systemd_lib
    tslib
    wayland
    xorg.fixesproto
    xorg.inputproto
    xorg.libX11
    xorg.libxcb
    xorg.libXext
    xorg.libXfixes
    xorg.libXi
    xorg.libXrender
    xorg.renderproto
    xorg.xcbutilimage
    xorg.xcbutilkeysyms
    xorg.xcbutilrenderutil
    xorg.xcbutilwm
    xorg.xextproto
    xorg.xproto
    zlib
  ] ++ optionals buildWebEngine [
    expat
    hunspell
    libcap
    pciutils
    xorg.compositeproto
    xorg.damageproto
    xorg.libXcomposite
    xorg.libXcursor
    xorg.libXdamage
    xorg.libXrandr
    xorg.libXtst
    xorg.libXScrnSaver
    xorg.randrproto
    xorg.recordproto
    xorg.scrnsaverproto
  ];

  # For some reason libdrm doesn't map drm.h correctly
  NIX_CFLAGS_COMPILE = "-I${libdrm}/include/libdrm";

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
    "-skip" "websockets"
    "-skip" "webview"
    "-skip" "winextras"
  ] ++ optionals (!buildWebEngine) [
    "-skip" "location"
    "-skip" "webchannel"
    "-skip" "webengine"
  ];

  # This is really broken and should be fixed uptream
  preFixup = ''
    find $out/lib/pkgconfig -name \*.pc -exec sed -i 's,Qt5UiPlugin,,g' {} \;
  '';

  # FIXME
  buildDirCheck = false;

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      md5Url = "https://download.qt.io/official_releases/qt/"
        + "${versionMajor}/${version}/single/md5sums.txt";
    };
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

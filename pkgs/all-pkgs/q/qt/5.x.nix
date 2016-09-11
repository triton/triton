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
, harfbuzz
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
, openssl
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
  versionMajor = "5.7";
  versionPatch = "0";
  version = "${versionMajor}.${versionPatch}";

  inherit (stdenv.lib)
    optionals;
in
stdenv.mkDerivation {
  name = "qt-${version}";

  src = fetchurl {
    url = "http://download.qt.io/official_releases/qt/${versionMajor}/${version}"
      + "/single/qt-everywhere-opensource-src-${version}.tar.xz";
    sha256 = "a6a2632de7e44bbb790bc3b563f143702c610464a7f537d02036749041fd1800";
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
    harfbuzz
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
    openssl
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

  preConfigure = ''
    configureFlagsArray+=(
      "-prefix" "$out"
    )
  '';

  configureFlags = [
    "-release"
    "-opensource"
    "-confirm-license"

    "-qt-sql-mysql"
    "-no-sql-odbc"
    "-no-sql-oci"
    "-qt-sql-psql"
    "-no-sql-tds"
    "-no-sql-db2"
    "-qt-sql-sqlite"
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
    "-nis"
    "-cups"
    "-iconv"
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
    "-directfb"
    "-linuxfb"
    "-no-mirclient"
    "-libinput"
    "-gstreamer" "1.0"
    "-system-proxies"
  ] ++ optionals (!buildWebEngine) [
    "-skip" "webengine"
  ];

  # This is really broken and should be fixed uptream
  preFixup = ''
    find $out/lib/pkgconfig -name \*.pc -exec sed -i 's,Qt5UiPlugin,,g' {} \;
  '';

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

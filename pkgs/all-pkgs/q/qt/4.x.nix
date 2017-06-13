{ stdenv
, fetchTritonPatch
, fetchurl
, substituteAll

, alsa-lib
, coreutils
, cups
, dbus
, fontconfig
, freetype
, glib
, gst-plugins-base
, gstreamer
, icu
, libjpeg
, libmng
, libpng
, libtiff
, mariadb-connector-c
, mesa_glu
, mesa_noglu
, openssl
, perl
, postgresql
, pulseaudio_lib
, sqlite
, which
, xorg
, zlib
}:

let
  inherit (stdenv.lib)
    optional
    optionals
    optionalString
    qtFlag
    versionAtLeast;
in

stdenv.mkDerivation rec {
  name = "qt-${version}";
  versionMajor = "4.8";
  versionMinor = "7";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "http://download.qt-project.org/official_releases/qt/${versionMajor}"
        + "/${version}/qt-everywhere-opensource-src-${version}.tar.gz";
    sha256 = "183fca7n7439nlhxyg1z7aky0izgbyll3iwakw4gwivy16aj5272";
  };

  nativeBuildInputs = [
    perl
    which
  ];

  buildInputs = [
    alsa-lib
    cups # Qt dlopen's libcups instead of linking to it
    dbus
    fontconfig
    freetype
    glib
    gst-plugins-base
    gstreamer
    icu
    libjpeg
    libmng
    libpng
    libtiff
    mariadb-connector-c
    mesa_glu
    mesa_noglu
    openssl
    postgresql
    pulseaudio_lib
    sqlite
    xorg.fixesproto
    xorg.inputproto
    xorg.kbproto
    xorg.libICE
    xorg.libSM
    xorg.libX11
    xorg.libXcursor
    xorg.libXext
    xorg.libXfixes
    xorg.libXi
    xorg.libXinerama
    xorg.libXrandr
    xorg.libXrender
    xorg.libXv
    xorg.randrproto
    xorg.renderproto
    xorg.videoproto
    xorg.xextproto
    xorg.xproto
    zlib
  ];

  prePatch = ''
    substituteInPlace configure \
      --replace /bin/pwd pwd
    substituteInPlace src/corelib/global/global.pri \
      --replace /bin/ls ${coreutils}/bin/ls
    sed -e 's@/\(usr\|opt\)/@/var/empty/@g' \
      -i config.tests/*/*.test \
      -i mkspecs/*/*.conf
  '';

  patches = optionals (versionAtLeast openssl.version "1.1.0") [
    (fetchTritonPatch {
      rev = "7c97a6a9ecdab5c104c195a64de96694902728ed";
      file = "q/qt/qt-4.8-openssl-1.1.0.patch";
      sha256 = "ff3ddb5428cd2ff243558dc0c75b35f470077e9204bbc989ddcba04c866c1b68";
    })
  ] ++ [
    (fetchTritonPatch {
      rev = "3a7e90a43079d94b6b1c4491ef3804d55c1e1216";
      file = "q/qt/qt-4.8-39_fix_medium_font.patch";
      sha256 = "7c909f2cf38897ae8537e0f37d2d9d0d97f37d1d7f2910115222004f49bb2d27";
    })
    (fetchTritonPatch {
      rev = "3a7e90a43079d94b6b1c4491ef3804d55c1e1216";
      file = "q/qt/qt-4.8-disable-sslv3.patch";
      sha256 = "829b02ba10f208c2beba8e8a0110b6d10c63932612dabc08d536f099b9f66101";
    })
    (fetchTritonPatch {
      rev = "3a7e90a43079d94b6b1c4491ef3804d55c1e1216";
      file = "q/qt/qt-4.8-glib-2.32.patch";
      sha256 = "9b019b4e62e8c9889748ad8772faf8436f5b47f2315bb9a68fdf9785784d1abf";
    })
    (fetchTritonPatch {
      rev = "a2a939c7e9045e6b5969ab70f6f096872e66be53";
      file = "q/qt/qt-4.8-icu59.patch";
      sha256 = "61d6bf45649c728dec5f8d22be5b496ed9d40f52c2c70102696d07133cd1750d";
    })
    (substituteAll {
      name = "qt-4.8-dlopen-absolute-paths.patch";
      src = fetchTritonPatch {
        rev = "f9b0e7835c04aea87181706a39344242e85db60c";
        file = "q/qt/qt-4.8-dlopen-absolute-paths.patch";
        sha256 = "d845a7e2fff67e0623d5895bcea8cc90940637e01efb217b1182fe12cf3c723b";
      };
      inherit cups icu;
      inherit (xorg) libXfixes;
      glibc = stdenv.cc.libc;
      openglDriver = mesa_noglu.driverSearchPath;
    })
  ];

  preConfigure = ''
    export LD_LIBRARY_PATH="`pwd`/lib:$LD_LIBRARY_PATH"
    configureFlags+=(
      "-docdir $out/share/doc/${name}"
      "-plugindir $out/lib/qt4/plugins"
      "-importdir $out/lib/qt4/imports"
      "-examplesdir $out/share/doc/${name}/examples"
      "-demosdir $out/share/doc/${name}/demos"
      "-datadir $out/share/${name}"
      "-translationdir $out/share/${name}/translations"
    )
  '' + optionalString stdenv.cc.isClang ''
    sed -e 's/QMAKE_CC = gcc/QMAKE_CC = clang/' \
      -i mkspecs/common/g++-base.conf
    sed -e 's/QMAKE_CXX = g++/QMAKE_CXX = clang++/' \
      -i mkspecs/common/g++-base.conf
  '';

  prefixKey = "-prefix ";

  configureFlags = [
    "-release"
    "-fast"
    "-no-debug"
    "-no-debug-and-release"
    "-no-developer-build"
    "-opensource"
    "-no-commercial"
    "-confirm-license"
    "-shared"
    "-no-static"
    "-largefile"
    #"-exceptions"
    "-accessibility"
    "-stl"
    "-plugin-sql-mysql"
    "-system-sqlite"
    "-no-qt3support"
    "-system-zlib"
    "-system-libtiff"
    "-system-libpng"
    "-system-libmng"
    "-system-libjpeg"
    "-rpath"
    "-verbose"
    "-no-silent"
    # Deprecated in glibc
    "-no-nis"
    "-cups"
    "-iconv"
    "-pch"
    "-dbus"
    "-dbus-linked"
    "-no-separate-debug-info"
    "-optimized-qmake"
    "-xmlpatterns"
    "-multimedia"
    # Provided by the phonon package
    "-no-phonon"
    "-no-phonon-backend"
    # Invalid switch
    ###"-media-backend"
    "-audio-backend"
    "-openssl"
    "-openssl-linked"
    "-no-gtkstyle"
    "-svg"
    "-no-webkit"
    "-no-javascript-jit"
    "-script"
    "-scripttools"
    "-declarative"
    "-system-proxies"
    ###"-graphics-system=raster,opengl,openvg"
    "-egl"
    "-opengl"
    "-no-openvg"
    "-sm"
    "-xshape"
    "-xsync"
    "-xinerama"
    "-xcursor"
    "-xfixes"
    "-xrandr"
    "-xrender"
    "-fontconfig"
    "-xinput"
    "-xkb"
    "-glib"

    "-make libs"
    "-make tools"
    "-make translations"
    "-nomake demos"
    "-nomake examples"
    "-nomake docs"
  ];

  CXXFLAGS = "-std=gnu++98";

  # FIXME
  buildDirCheck = false;

  meta = with stdenv.lib; {
    description = "A cross-platform application framework for C++";
    homepage = http://qt-project.org/;
    license = licenses.lgpl21Plus; # or gpl3
    maintainers = with maintainers; [ ];
    platforms = with platforms;
      x86_64-linux;
  };
}

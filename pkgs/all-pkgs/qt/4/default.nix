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
, mesa_glu
, mesa_noglu
, mysql_lib
, openssl
, perl
, postgresql
, pulseaudio_lib
, sqlite
, which
, xorg
, zlib
}:

with {
  inherit (stdenv.lib)
    optional
    optionals
    optionalString
    qtFlag;
};

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
    mesa_glu
    mesa_noglu
    mysql_lib
    openssl
    postgresql
    pulseaudio_lib
    sqlite
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

  patches = [
    (fetchTritonPatch {
      rev = "1d82577840200894c2b4ca4b025eb809f8dd9b51";
      file = "qt/qt-4.8-glib-2.32.patch";
      sha256 = "9b019b4e62e8c9889748ad8772faf8436f5b47f2315bb9a68fdf9785784d1abf";
    })
    (fetchTritonPatch {
      rev = "1d82577840200894c2b4ca4b025eb809f8dd9b51";
      file = "qt/qt-4.8-libressl.patch";
      sha256 = "2535881d17d9a886b39bb6ed980e16d974bc3109bb7a7053ddf521e230ea547b";
    })
    (substituteAll {
      src = ./qt-4.8-dlopen-absolute-paths.patch;
      inherit cups icu;
      inherit (xorg) libXfixes;
      glibc = stdenv.cc.libc;
      openglDriver = mesa_noglu.driverSearchPath;
    })
    (fetchTritonPatch {
      rev = "1d82577840200894c2b4ca4b025eb809f8dd9b51";
      file = "qt/qt-4.8-39_fix_medium_font.patch";
      sha256 = "7c909f2cf38897ae8537e0f37d2d9d0d97f37d1d7f2910115222004f49bb2d27";
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

  meta = with stdenv.lib; {
    description = "A cross-platform application framework for C++";
    homepage = http://qt-project.org/;
    license = licenses.lgpl21Plus; # or gpl3
    maintainers = with maintainers; [ ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}

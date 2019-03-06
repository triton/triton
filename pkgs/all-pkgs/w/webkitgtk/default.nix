{ stdenv
, bison
, cmake
, fetchurl
, gettext
, gperf
, lib
, ninja
, perl
, python2
, ruby

, at-spi2-core
, atk
, bubblewrap
, cairo
, enchant
, fontconfig
, freetype
, gdk-pixbuf
, geoclue
, glib
, gobject-introspection
, gst-plugins-bad
, gst-plugins-base
, gstreamer
, gtk3
, harfbuzz_lib
, icu
, libgcrypt
, libjpeg
, libnotify
, libpng
, libseccomp
, libsecret
, libsoup
, libtasn1
, libwebp
, libx11
, libxcomposite
, libxdamage
, libxfixes
, libxml2
, libxrender
, libxt
, libxslt
, opengl-dummy
, openjpeg
, pango
, sqlite
, wayland
, xorgproto
, zlib
}:

let
  inherit (lib)
    boolOn;
in
stdenv.mkDerivation rec {
  name = "webkitgtk-2.22.7";

  src = fetchurl {
    url = "https://webkitgtk.org/releases/${name}.tar.xz";
    hashOutput = false;
    sha256 = "4be6f7d605cd0a690fd26e8aa83b089a33ad9d419148eafcfb60580dd2af30ff";
  };

  # Source/cmake/WebKitCommon.cmake
  nativeBuildInputs = [
    bison
    cmake
    gettext
    gperf
    ninja
    perl
    python2
    ruby
  ];

  buildInputs = [
    at-spi2-core
    atk
    bubblewrap
    cairo
    enchant
    fontconfig
    freetype
    gdk-pixbuf
    geoclue
    glib
    gobject-introspection
    gst-plugins-bad
    gst-plugins-base
    gstreamer
    gtk3
    harfbuzz_lib
    icu
    libgcrypt
    libjpeg
    libnotify
    libpng
    libseccomp
    libsecret
    libsoup
    libtasn1
    libwebp
    libx11
    libxcomposite
    libxdamage
    libxfixes  # FIXME: libxcomposite dep not discovered via pkgconfig
    libxml2
    libxrender
    libxt
    libxslt
    opengl-dummy
    openjpeg
    pango
    sqlite
    wayland
    #xdg-dbus-proxy  # FIXME
    xorgproto
    zlib
  ];

  postPatch = ''
    patchShebangs Tools/
    patchShebangs Source/WebInspectorUI/Scripts/copy-user-interface-resources.pl
  '';

  cmakeFlags = [
    "-DPORT=GTK"
    "-DDEVELOPER_MODE=OFF"
    "-DENABLE_DEVELOPER_MODE=OFF"
    # Source/cmake/OptionsCommon.cmake
    "-DUSE_LD_GOLD=ON"
    # Source/cmake/WebKitFeatures.cmake
    "-DENABLE_ACCESSIBILITY=ON"
    "-DENABLE_GAMEPAD=ON"
    "-DENABLE_SPELLCHECK=OFF"  # FIXME: Update enchant
    "-DENABLE_MEDIA_STREAM=OFF"  # FIXME
    "-DENABLE_WEB_RTC=OFF"  # FIXME
    "-DENABLE_EXPERIMENTAL_FEATURES=ON"
    # Source/cmake/OptionsGTK.cmake
    "-DENABLE_OPENGL=${boolOn (opengl-dummy != null)}"  # FIXME: add opengl-dummy any interface
    "-DENABLE_GLES2=${boolOn opengl-dummy.glesv2}"
    "-DENABLE_PLUGIN_PROCESS_GTK2=OFF"
    "-DENABLE_X11_TARGET=ON"
    "-DENABLE_WAYLAND_TARGET=ON"  # FIXME: require egl
    "-DUSE_LIBHYPHEN=OFF"  # FIXME
    "-DUSE_WOFF2=OFF"  # FIXME
    "-DUSE_OPENVR=OFF"  # FIXME
    #"ENABLE_NETSCAPE_PLUGIN_API"
    # Source/cmake/GStreamerDefinitions.cmake
    "-DUSE_GSTREAMER_GL=OFF"  # FIXME
    "-DUSE_GSTREAMER_MPEGTS=ON"
  ];

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      fullOpts = {
        #sha256Urls = map (u: "${u}.sums") src.urls;
        pgpsigUrls = map (u: "${u}.asc") src.urls;
        pgpKeyFingerprints = [
          "5AA3 BC33 4FD7 E336 9E7C  77B2 91C5 59DB E4C9 123B"
        ];
      };
      failEarly = true;
    };
  };

  meta = with lib; {
    description = "Web content rendering engine, GTK+ port";
    homepage = "http://webkitgtk.org/";
    license = licenses.bsd2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

{ stdenv
, bison
, cmake
, fetchurl
, gettext
, gperf
, perl
, python
, ruby

, at-spi2-core
, atk
, cairo
, enchant
, fontconfig
, freetype
, gdk-pixbuf
, geoclue2
, glib
, gobject-introspection
, gnutls
, gst-plugins-base
, gstreamer
, gtk2
, gtk3
, harfbuzz
, icu
, libjpeg
, libnotify
, libpng
, libsecret
, libsoup
, libwebp
, libxml2
, libxslt
, mesa_noglu
, pango
, sqlite
, wayland
, xorg
, zlib

# gtkunixprint
# gudev
# openwebrtc
# libseccomp
# libhyphen
}:

with {
  inherit (stdenv.lib)
    cmFlag;
};

stdenv.mkDerivation rec {
  name = "webkitgtk-2.10.4";

  src = fetchurl {
    url = "http://webkitgtk.org/releases/${name}.tar.xz";
    sha256 = "0mghsbfnmmf6nsf7cb3ah76s77aigkzf3k6kw96wgh6all6jdy6v";
  };

  patches = [
    ./finding-harfbuzz-icu.patch
  ];

  patchPhase = ''
    patchShebangs ./Tools
  '';

  cmakeFlags = [
    (cmFlag "CMAKE_BUILD_TYPE" "Release")
    (cmFlag "PORT" "GTK")
    (cmFlag "ENABLE_PLUGIN_PROCESS_GTK2" (gtk2 != null))

    (cmFlag "ENABLE_WEBKIT" true)
    (cmFlag "ENABLE_WEBKIT2" true)
    (cmFlag "ENABLE_TOOLS" true)
    # Shared library causes linker failure
    (cmFlag "SHARED_CORE" false)
    (cmFlag "ENABLE_API_TESTS" false)

    (cmFlag "ENABLE_GRAPHICS_CONTEXT_3D" true)
    (cmFlag "ENABLE_GTKDOC" false)
    (cmFlag "ENABLE_INTROSPECTION" (gobject-introspection != null))
    (cmFlag "USE_REDIRECTED_XCOMPOSITE_WINDOW" true)

    (cmFlag "ENABLE_DEVELOPER_MODE" false)

    # Optional libraries
    (cmFlag "ENABLE_CREDENTIAL_STORAGE" (libsecret != null))
    (cmFlag "ENABLE_JIT" true)
    (cmFlag "ENABLE_FTL_JIT" false) # llvm
    # TODO: add gudev support
    (cmFlag "ENABLE_GAMEPAD_DEPRECATED" false)
    (cmFlag "ENABLE_GEOLOCATION" (geoclue2 != null))
    # TODO: add openwebrtc support
    (cmFlag "ENABLE_MEDIA_STREAM" false)
    (cmFlag "ENABLE_OPENGL" (mesa_noglu != null))
    (cmFlag "ENABLE_GLES2" (mesa_noglu != null))
    (cmFlag "ENABLE_PLUGIN_PROCESS_GTK2" (gtk2 != null))
    (cmFlag "ENABLE_SECCOMP_FILTERS" false)
    (cmFlag "ENABLE_SPELLCHECK" (enchant != null))
    (cmFlag "ENABLE_SUBTLE_CRYPTO" (gnutls != null))
    (cmFlag "ENABLE_VIDEO" (gstreamer != null && gst-plugins-base != null))
    (cmFlag "ENABLE_WEB_AUDIO" (gstreamer != null && gst-plugins-base != null))
    # TODO: add gstreamer mpeg-ts support
    (cmFlag "USE_GSTREAMER_MPEGTS" false)
    # TODO: add gstreamer GL support
    (cmFlag "USE_GSTREAMER_GL" (gstreamer != null && gst-plugins-base != null))
    (cmFlag "ENABLE_X11_TARGET" (xorg.libX11 != null))
    # TODO: add wayland support (linker errors)
    (cmFlag "ENABLE_WAYLAND_TARGET" (wayland != null))
    (cmFlag "USE_LIBNOTIFY" (libnotify != null))
    # TODO: add libhyphen support
    (cmFlag "USE_LIBHYPHEN" false)

    #ENABLE_PLUGIN_PROCESS
    #ENABLE_NETWORK_PROCESS
    #ENABLE_DATABASE_PROCESS
    #ENABLE_ICONDATABASE
    #ENABLE_THREADED_COMPOSITOR
    #ENABLE_BATTERY_STATUS
    #ENABLE_ACCESSIBILITY
    #ENABLE_ALLINONE_BUILD
    #ENABLE_ENCRYPTED_MEDIA
    #ENABLE_WEBGL
    #ENABLE_VIDEO_TRACK
    #ENABLE_QUOTA
    #USE_EGL
    #ENABLE_WEB_REPLAY
    #ENABLE_USER_MESSAGE_HANDLERS
    #WebCore_USER_AGENT_SCRIPTS
    #ENABLE_SVG_FONTS
    #ENABLE_GEOLOCATION
    #USE_GEOCLUE2
    #USE_TEXTURE_MAPPER
    #USE_OPENGL_ES_2
    #USE_OPENGL
    #ENABLE_SMOOTH_SCROLLING
    #ENABLE_INDEXED_DATABASE
    #USE_LD_GOLD
    #ENABLE_ECORE_X
    #ENABLE_ACCESSIBILITY
    #ENABLE_NETSCAPE_PLUGIN_API
    #ENABLE_EGL
    #ENABLE_SPEECH_SYNTHESIS
  ];

  # WebKit2 missing include path for gst-plugins-base.
  # https://bugs.webkit.org/show_bug.cgi?id=148894
  NIX_CFLAGS_COMPILE = [
    "-I${gst-plugins-base}/include/gstreamer-1.0"
  ];

  nativeBuildInputs = [
    bison
    cmake
    gettext
    gperf
    perl
    python
    ruby
  ];

  buildInputs = [
    at-spi2-core
    atk
    cairo
    enchant
    fontconfig
    freetype
    gdk-pixbuf
    geoclue2
    glib
    gobject-introspection
    gnutls
    gst-plugins-base
    gstreamer
    gtk2
    gtk3
    harfbuzz
    icu
    libjpeg
    libnotify
    libpng
    libsecret
    libsoup
    libwebp
    libxml2
    libxslt
    mesa_noglu
    pango
    sqlite
    wayland
    xorg.libX11
    xorg.libXau
    xorg.libXcomposite
    xorg.libXcursor
    xorg.libXdamage
    xorg.libXext
    xorg.libXi
    xorg.libXinerama
    xorg.libXrandr
    xorg.libXrender
    xorg.libXt
    zlib
  ];

  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    description = "Web content rendering engine, GTK+ port";
    homepage = "http://webkitgtk.org/";
    license = licenses.bsd2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];
  };
}

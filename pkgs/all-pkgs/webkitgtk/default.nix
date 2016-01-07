{ stdenv
, bison
, cmake
, fetchurl
, gettext
, gperf
, perl
, python
, ruby

# Required
, atk
, cairo
, fontconfig
, freetype
, glib
, gtk3
, harfbuzz
, icu
, libjpeg
, libpng
, libsoup
, libwebp
, libxml2
, libxslt
, sqlite
, zlib

# Optional
, at-spi2-core
, enchant
, geoclue2
, gobject-introspection
, gnutls
, gst_all_1
, gtk2
, libnotify
, libsecret
, llvmPackages
, mesa_noglu
, wayland
, xorg
# gtkunixprint
# gudev
# openwebrtc
# libseccomp
# libhyphen


#, pango
}:

with {
  inherit (stdenv.lib)
    cmFlag;
};

stdenv.mkDerivation rec {
  name = "webkitgtk-2.10.3";

  src = fetchurl {
    url = "http://webkitgtk.org/releases/${name}.tar.xz";
    sha256 = "0lj0nq7l1w5j673x902pgalzrm9njbh8b0419l385b4vxarf0gib";
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
    (cmFlag "ENABLE_PLUGIN_PROCESS_GTK2" true)

    (cmFlag "ENABLE_WEBKIT" true)
    (cmFlag "ENABLE_WEBKIT2" true)
    (cmFlag "ENABLE_TOOLS" true)
    # Shared library causes linker failure
    (cmFlag "SHARED_CORE" false)
    (cmFlag "ENABLE_API_TESTS" false)

    (cmFlag "ENABLE_GRAPHICS_CONTEXT_3D" true)
    (cmFlag "ENABLE_GTKDOC" false)
    (cmFlag "ENABLE_INTROSPECTION" true)
    (cmFlag "USE_REDIRECTED_XCOMPOSITE_WINDOW" true)

    (cmFlag "ENABLE_DEVELOPER_MODE" false)

    # Optional libraries
    (cmFlag "ENABLE_CREDENTIAL_STORAGE" true)
    (cmFlag "ENABLE_JIT" true)
    # TODO: add llvm support, disables internal jit?
    (cmFlag "ENABLE_FTL_JIT" false)
    # TODO: add gudev support
    (cmFlag "ENABLE_GAMEPAD_DEPRECATED" false)
    (cmFlag "ENABLE_GEOLOCATION" (geoclue2 != null))
    # TODO: add openwebrtc support
    (cmFlag "ENABLE_MEDIA_STREAM" false)
    (cmFlag "ENABLE_OPENGL" true)
    (cmFlag "ENABLE_GLES2" true)
    (cmFlag "ENABLE_PLUGIN_PROCESS_GTK2" true)
    (cmFlag "ENABLE_SECCOMP_FILTERS" false)
    (cmFlag "ENABLE_SPELLCHECK" true)
    (cmFlag "ENABLE_SUBTLE_CRYPTO" true)
    (cmFlag "ENABLE_VIDEO" true)
    (cmFlag "ENABLE_WEB_AUDIO" true)
    # TODO: add gstreamer mpeg-ts support
    (cmFlag "USE_GSTREAMER_MPEGTS" false)
    # TODO: add gstreamer GL support
    (cmFlag "USE_GSTREAMER_GL" false)
    (cmFlag "ENABLE_X11_TARGET" true)
    # TODO: add wayland support (linker errors)
    (cmFlag "ENABLE_WAYLAND_TARGET" true )
    (cmFlag "USE_LIBNOTIFY" true)
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
    "-I${gst_all_1.gst-plugins-base}/include/gstreamer-1.0"
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
    # Required
    atk
    cairo
    fontconfig
    freetype
    glib
    gtk3
    harfbuzz
    icu
    libjpeg
    libpng
    libsoup
    libwebp
    libxml2
    libxslt
    sqlite
    zlib
    # Optional
    at-spi2-core
    enchant
    geoclue2
    gobject-introspection
    gnutls
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gtk2
    libnotify
    libsecret
    llvmPackages.llvm
    mesa_noglu # egl, opengl, opengles2
    wayland
    xorg.libXt
    xorg.libXau
    xorg.libXcomposite
    xorg.libXrender
    xorg.libXdamage
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

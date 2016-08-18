{ stdenv
, bison
, cmake
, fetchTritonPatch
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
, geoclue
, glib
, gobject-introspection
, gnutls
, gst-plugins-base
, gstreamer
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
    cmFlag
    optionals;
};

assert xorg != null ->
  xorg.libX11 != null;

stdenv.mkDerivation rec {
  name = "webkitgtk-2.12.3";

  src = fetchurl rec {
    url = "https://webkitgtk.org/releases/${name}.tar.xz";
    sha1Url = url + ".sha1";
    sha256 = "173cbb9a2eca23eee52e99965483ab25aa9c0569ef5b57041fc0c129cc26c307";
  };

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
    geoclue
    glib
    gobject-introspection
    gnutls
    gst-plugins-base
    gstreamer
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
  ] ++ optionals (xorg != null) [
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

  patches = [
    (fetchTritonPatch {
      rev = "7a86b94c61553bfa090488c0b73c477bdc062b7c";
      file = "webkitgtk/webkit-gtk-2.10.x-finding-harfbuzz-icu.patch";
      sha256 = "8eb3f4844b06c3c060233396045248a883177e9a09c491ddfaf9897d8e8ca2c4";
    })
  ];

  postPatch = ''
    patchShebangs ./Tools
  '';

  cmakeFlags = [
    (cmFlag "CMAKE_BUILD_TYPE" "Release")
    (cmFlag "PORT" "GTK")
    (cmFlag "ENABLE_PLUGIN_PROCESS_GTK2" false)

    (cmFlag "ENABLE_WEBKIT" false)
    (cmFlag "ENABLE_WEBKIT2" true)
    (cmFlag "ENABLE_TOOLS" true)
    # Shared library causes linker failures
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
    (cmFlag "ENABLE_GEOLOCATION" (geoclue != null))
    # TODO: add openwebrtc support
    (cmFlag "ENABLE_MEDIA_STREAM" false)
    (cmFlag "ENABLE_OPENGL" (mesa_noglu != null))
    (cmFlag "ENABLE_GLES2" (mesa_noglu != null))
    (cmFlag "ENABLE_PLUGIN_PROCESS_GTK2" false)
    (cmFlag "ENABLE_SECCOMP_FILTERS" false)
    (cmFlag "ENABLE_SPELLCHECK" (enchant != null))
    (cmFlag "ENABLE_SUBTLE_CRYPTO" (gnutls != null))
    (cmFlag "ENABLE_VIDEO" (gstreamer != null && gst-plugins-base != null))
    (cmFlag "ENABLE_WEB_AUDIO" (gstreamer != null && gst-plugins-base != null))
    # TODO: add gstreamer mpeg-ts support
    (cmFlag "USE_GSTREAMER_MPEGTS" false)
    # TODO: add gstreamer GL support
    (cmFlag "USE_GSTREAMER_GL" false)
    (cmFlag "ENABLE_X11_TARGET" (xorg != null))
    # TODO: add wayland support (linker errors)
    (cmFlag "ENABLE_WAYLAND_TARGET" (wayland != null))
    (cmFlag "USE_LIBNOTIFY" (libnotify != null))
    # TODO: add libhyphen support
    (cmFlag "USE_LIBHYPHEN" false)
  ];

  # WebKit2 missing include path for gst-plugins-base.
  # https://bugs.webkit.org/show_bug.cgi?id=148894
  NIX_CFLAGS_COMPILE = [
    "-I${gst-plugins-base}/include/gstreamer-1.0"
  ];

  meta = with stdenv.lib; {
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
